"""Run BaseSwiftUI task/identity regressions on the host; not iOS runtime UI tests."""
from pathlib import Path
import os
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
HARNESS = r'''
import Combine
import Foundation

#if os(macOS)
extension IndexPath {
    init(row: Int, section: Int) { self.init(indexes: [section, row]) }
    var row: Int { self[1] }
}
#endif

struct TestState: DefaultInitializable { init() {} }
enum TestFeature: MVIFeature {
    typealias State = TestState
    typealias Intent = Never
}
typealias TestOwner = BaseContainer<TestFeature>

struct Row: Identifiable, Equatable {
    let id: Int
    let text: String
}

@MainActor
final class Gate {
    private(set) var started = false
    private var continuation: CheckedContinuation<Void, Never>?
    func wait() async {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            started = true
        }
    }
    func resume() { continuation?.resume(); continuation = nil }
    func waitUntilStarted() async {
        for _ in 0..<1000 {
            if started { return }
            await Task.yield()
        }
        preconditionFailure("Task did not reach gate")
    }
}

@main
struct CoreChecks {
    @MainActor
    static func main() async {
        let old = Row(id: 1, text: "old")
        let current = Row(id: 1, text: "updated")
        let removed = Row(id: 2, text: "removed")
        let source = BaseDataSource<Row>()
        source.setListItem([old, removed])
        var selected: [Row] = []
        var visible: [Row] = []
        var indices: [Int] = []
        let a = source.selectedValue.sink { selected.append($0) }
        let b = source.visibleValue.sink { visible.append($0) }
        let c = source.tappedItemSubject.sink { indices.append($0.1.row) }
        source.setListItem( [Row(id: 3, text: "first"), current])
        precondition(source.select(old) == current)
        source.markVisible(old)
        precondition(source.select(removed) == nil)
        source.select(removed)
        source.markVisible(removed)
        precondition(selected == [current] && visible == [current] && indices == [1])
        withExtendedLifetime((a, b, c)) {}

        let owner = TestOwner()
        var ranCancelledWork = false
        let cancelled = owner.runTask(id: "cancel") { ranCancelledWork = true }
        owner.cancelTask(id: "cancel")
        await cancelled.value
        precondition(!ranCancelledWork && !owner.isLoading)

        let oldGate = Gate(), newGate = Gate()
        let oldTask = owner.runTask(id: "replace") { await oldGate.wait() }
        await oldGate.waitUntilStarted()
        let newTask = owner.runTask(id: "replace") { await newGate.wait() }
        await newGate.waitUntilStarted()
        oldGate.resume()
        await oldTask.value
        precondition(owner.isLoading, "Stale completion cleared replacement loading")
        newGate.resume()
        await newTask.value
        precondition(!owner.isLoading)

        let firstGate = Gate(), secondGate = Gate()
        let first = owner.runTask(id: "first") { await firstGate.wait() }
        let second = owner.runTask(id: "second") { await secondGate.wait() }
        await firstGate.waitUntilStarted()
        await secondGate.waitUntilStarted()
        firstGate.resume()
        await first.value
        precondition(owner.isLoading, "One completion cleared unrelated loading")
        secondGate.resume()
        await second.value
        precondition(!owner.isLoading)

        let lifetimeGate = Gate()
        var temporary: TestOwner? = TestOwner()
        weak var weakOwner = temporary
        let task = temporary!.runTask(id: "lifetime") { await lifetimeGate.wait() }
        await lifetimeGate.waitUntilStarted()
        temporary = nil
        precondition(weakOwner == nil, "Task manager retained owner across await")
        precondition(task.isCancelled, "Deinit did not cancel owned task")
        lifetimeGate.resume()
        await task.value
        print("Core behavior: identity/update/removal, cancellation, replacement, independent loading, owner lifetime PASSED")
    }
}
'''


def main():
    env = dict(os.environ)
    env.setdefault('DEVELOPER_DIR', '/Applications/Xcode.app/Contents/Developer')
    with tempfile.TemporaryDirectory(prefix='BaseSwiftUI-behavior-') as folder:
        temp = Path(folder)
        harness = temp / 'CoreChecks.swift'
        harness.write_text(HARNESS)
        mvi = ROOT / 'BaseSwiftUI/Base/MVI'
        files = [mvi / name for name in ['DefaultInitializable.swift', 'MVIFeature.swift',
                                        'MVIContainer.swift', 'BaseContainer.swift']]
        files += [ROOT / 'BaseSwiftUI/Base/DataSource/Core/BaseDataSource.swift', harness]
        subprocess.run(['xcrun', '--sdk', 'macosx', 'swiftc', '-swift-version', '5',
                        '-parse-as-library', '-module-cache-path', str(temp / 'cache'),
                        *map(str, files), '-o', str(temp / 'checks')], env=env, check=True)
        subprocess.run([str(temp / 'checks')], env=env, check=True, timeout=30)


if __name__ == '__main__':
    main()
