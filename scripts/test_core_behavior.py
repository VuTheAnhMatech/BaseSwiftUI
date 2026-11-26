"""Run BaseSwiftUI task/identity regressions on the host; not iOS runtime UI tests."""
from pathlib import Path
import os
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
HARNESS = r'''
import Combine
import Foundation
import SwiftUI

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

enum EffectFeature: MVIFeature {
    struct State: DefaultInitializable { var count = 0 }
    enum Intent { case increment }
    enum Effect: Equatable { case incremented(Int) }
}
final class EffectOwner: BaseContainer<EffectFeature> {
    override func dispatch(_ intent: EffectFeature.Intent) async {
        updateState { $0.count += 1 }
        sendEffect(.incremented(state.count))
    }
}
struct FixtureRepository: HomePostRepository {
    let posts: [HomePost]
    func fetchPosts() async throws -> [HomePost] { posts }
}
struct FixtureUseCase: LoadHomePostsUseCase {
    let posts: [HomePost]
    func execute() async throws -> [HomePost] { posts }
}


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

enum LifecycleFeature: MVIFeature {
    struct State: DefaultInitializable { var events: [String] = [] }
    enum Intent { case record(String), wait(Gate) }
    typealias Effect = String
}
final class LifecycleOwner: BaseContainer<LifecycleFeature> {
    var disappearGate: Gate?
    override func dispatch(_ intent: LifecycleFeature.Intent) async {
        switch intent {
        case .record(let value):
            updateState { $0.events.append(value) }
            sendEffect(value)
        case .wait(let gate):
            await gate.wait()
            updateState { $0.events.append("wait finished") }
            sendEffect("wait finished")
        }
    }
    override func dispatchSystem(_ intent: SystemIntent) async {
        switch intent {
        case .onAppear: updateState { $0.events.append("appear") }
        case .onDisappear:
            await disappearGate?.wait()
            updateState { $0.events.append("disappear") }
            sendEffect("disappear")
            runTask(id: "cleanup", showsLoading: false) { [weak self] in
                self?.updateState { $0.events.append("cleanup") }
            }
        default: updateState { $0.events.append("environment") }
        }
    }
}

enum StorageFailure: Error { case unavailable }
final class MemorySecureStorage: SecureTokenStorage {
    var data: Data?
    var failsRead = false
    var failsWrite = false
    var failsDelete = false
    func read() throws -> Data? {
        if failsRead { throw StorageFailure.unavailable }
        return data
    }
    func write(_ data: Data) throws {
        if failsWrite { throw StorageFailure.unavailable }
        self.data = data
    }
    func delete() throws {
        if failsDelete { throw StorageFailure.unavailable }
        data = nil
    }
}
final class MemoryDefaults: UserDefaults {
    private var values: [String: String] = [:]
    override func string(forKey key: String) -> String? { values[key] }
    override func set(_ value: Any?, forKey key: String) { values[key] = value as? String }
    override func removeObject(forKey key: String) { values.removeValue(forKey: key) }
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
        let effectsOwner = EffectOwner()
        var effects: [EffectFeature.Effect] = []
        let firstEffectSubscription = effectsOwner.effects.sink { effects.append($0) }
        await effectsOwner.dispatch(.increment)
        firstEffectSubscription.cancel()
        var replayed: [EffectFeature.Effect] = []
        let secondEffectSubscription = effectsOwner.effects.sink { replayed.append($0) }
        precondition(effects == [.incremented(1)] && replayed.isEmpty, "Effects must not replay to a new View")
        await effectsOwner.dispatch(.increment)
        precondition(replayed == [.incremented(2)] && effectsOwner.state.count == 2)
        withExtendedLifetime(secondEffectSubscription) {}

        let post = HomePost(id: 1, title: "First", body: "Body")
        let nextPost = HomePost(id: 2, title: "Second", body: "Body")
        let filtered = try! await LoadHomePosts(repository: FixtureRepository(posts: [
            post, HomePost(id: 1, title: "Duplicate", body: ""),
            HomePost(id: 3, title: "  ", body: ""), nextPost
        ])).execute()
        precondition(filtered.map(\.id) == [1, 2], "Domain filtering/order must survive migration")
        let home = HomeContainer(loadPosts: FixtureUseCase(posts: [post]))
        await home.dispatchSystem(.onAppear)
        for _ in 0..<1000 {
            if home.state.hasLoaded { break }
            await Task.yield()
        }
        precondition(home.state.hasLoaded && !home.state.isEmpty)
        var selectedRoute: AppRoute?
        let homeEffects = home.effects.sink { if case .navigate(let route) = $0 { selectedRoute = route } }
        await home.dispatch(.select(HomeItem(post: post)))
        precondition(selectedRoute == .detail(HomeItem(post: post)))
        withExtendedLifetime(homeEffects) {}

        let navigation = AppNavigationState(root: .home)
        let originalRoot = navigation.root
        let rootRouter = navigation.router(for: originalRoot)
        let detail = AppRoute.detail(HomeItem(post: post))
        rootRouter.navigate(to: detail, .push)
        rootRouter.navigate(to: .home, .sheet)
        let sheet = originalRoot.sheet!
        let sheetRouter = navigation.router(for: sheet)
        sheetRouter.navigate(to: detail, .push)
        precondition(originalRoot.path == [detail] && sheet.path == [detail], "Sheet push leaked to root")
        sheetRouter.goBack()
        precondition(sheet.path.isEmpty && originalRoot.path == [detail])
        sheetRouter.navigate(to: .wallpaperPaywall, .modal)
        let modal = sheet.modal!
        navigation.router(for: modal).dismiss()
        sheet.presentationDidDismiss(.modal)
        precondition(sheet.modal == nil && originalRoot.sheet === sheet, "Modal dismiss removed parent sheet")
        sheetRouter.navigate(to: .home, .sheet)
        let nestedSheet = sheet.sheet!
        navigation.router(for: nestedSheet).navigate(to: detail)
        precondition(sheet.path.isEmpty && nestedSheet.path == [detail], "Nested stack ownership was lost")
        navigation.router(for: nestedSheet).dismiss()
        sheet.presentationDidDismiss(.sheet)
        precondition(sheet.sheet == nil && originalRoot.sheet === sheet)
        sheetRouter.dismiss()
        originalRoot.presentationDidDismiss(.sheet)
        precondition(originalRoot.sheet == nil && originalRoot.path == [detail])
        rootRouter.goBack()
        precondition(originalRoot.path.isEmpty, "Back after sheet dismissal corrupted parent stack")
        rootRouter.navigate(to: detail)
        rootRouter.navigate(to: .detail(HomeItem(post: nextPost)))
        rootRouter.pop(to: .detail)
        precondition(originalRoot.path.count == 2, "pop(to:) must select nearest matching route key")
        rootRouter.pop(to: .home)
        precondition(originalRoot.path.isEmpty)
        rootRouter.navigate(to: .home, .fadeCover)
        navigation.router(for: originalRoot.fadeCover!).dismiss()
        originalRoot.presentationDidDismiss(.fadeCover)
        precondition(originalRoot.fadeCover == nil)
        rootRouter.navigate(to: .home, .sheet)
        let dismissedRouter = navigation.router(for: originalRoot.sheet!)
        dismissedRouter.navigate(to: .translationDemo(showPaywall: false), .asRoot)
        precondition(navigation.root.route == .translationDemo(showPaywall: false))
        precondition(navigation.root.path.isEmpty && navigation.root.sheet == nil)
        rootRouter.navigate(to: detail)
        dismissedRouter.navigate(to: detail)
        precondition(navigation.root.path.isEmpty, "An obsolete router mutated the replacement root")

        let demo = TranslationDemoContainer(showPaywall: true)
        var paywallPresentations = 0
        let demoEffects = demo.effects.sink { _ in paywallPresentations += 1 }
        await demo.dispatchSystem(.onAppear)
        await demo.dispatchSystem(.onAppear)
        precondition(paywallPresentations == 1, "Paywall preview reopened on reappearance")
        await demo.dispatch(.openPaywall)
        precondition(paywallPresentations == 2)
        withExtendedLifetime(demoEffects) {}
        // Public send() serializes intents even when the first handler suspends.
        let eventsOwner = LifecycleOwner()
        var liveEffects: [String] = []
        let eventSubscription = eventsOwner.effects.sink { liveEffects.append($0) }
        await eventsOwner.sendSystem(.onAppear).value
        let orderedGate = Gate()
        let waiting = eventsOwner.send(.wait(orderedGate))
        await orderedGate.waitUntilStarted()
        let queued = eventsOwner.send(.record("second"))
        precondition(eventsOwner.state.events == ["appear"])
        orderedGate.resume()
        await queued.value
        await waiting.value
        precondition(eventsOwner.state.events == ["appear", "wait finished", "second"])
        precondition(liveEffects == ["wait finished", "second"])

        let cancelledGate = Gate()
        let staleIntent = eventsOwner.send(.wait(cancelledGate))
        await cancelledGate.waitUntilStarted()
        let discarded = eventsOwner.send(.record("discarded"))
        let cleanupGate = Gate()
        eventsOwner.disappearGate = cleanupGate
        let disappearTask = eventsOwner.sendSystem(.onDisappear)
        await cleanupGate.waitUntilStarted()
        let appearance = eventsOwner.sendSystem(.onAppear)
        await appearance.value
        await eventsOwner.send(.record("fresh")).value
        let expectedEvents = eventsOwner.state.events
        let expectedEffects = liveEffects
        cancelledGate.resume()
        cleanupGate.resume()
        await staleIntent.value
        await discarded.value
        await disappearTask.value
        await Task.yield()
        precondition(eventsOwner.state.events == expectedEvents, "Cancelled lifecycle/intent changed new session")
        precondition(liveEffects == expectedEffects, "Cancelled lifecycle emitted a stale effect")
        precondition(!eventsOwner.isLoading)
        let pending = eventsOwner.send(.record("cancel before start"))
        eventsOwner.cancelAllTasks()
        await pending.value
        precondition(!eventsOwner.state.events.contains("cancel before start"))
        let quickDisappear = eventsOwner.sendSystem(.onDisappear)
        let quickAppear = eventsOwner.sendSystem(.onAppear)
        await quickDisappear.value
        await quickAppear.value
        await eventsOwner.sendSystem(.colorSchemeChanged(.dark)).value
        precondition(eventsOwner.state.events.suffix(2) == ["appear", "environment"])
        withExtendedLifetime(eventSubscription) {}

        // Dismiss completion is exactly once, including native swipe, parent close and root replacement.
        let callbackNav = AppNavigationState(root: .home)
        let callbackRoot = callbackNav.root
        let callbackRouter = callbackNav.router(for: callbackRoot)
        var callbacks: [String] = []
        callbackRouter.navigate(to: .home, .sheet,
            sheet: SheetConfiguration(detents: [.medium, .large], selectedDetent: .medium),
            onDismiss: {
                callbacks.append("sheet")
                callbackRouter.navigate(to: .home, .modal)
            })
        let callbackSheet = callbackRoot.sheet!
        let callbackSheetRouter = callbackNav.router(for: callbackSheet)
        precondition(callbackSheetRouter.selectedSheetDetent == .medium)
        callbackSheet.selectSheetDetent(.large) // SwiftUI selection binding setter.
        precondition(callbackSheetRouter.selectedSheetDetent == .large)
        callbackSheetRouter.updateSheet(SheetConfiguration(detents: [.medium, .large]))
        precondition(callbackSheetRouter.selectedSheetDetent == .large)
        callbackSheetRouter.updateSheet(SheetConfiguration(detents: [.medium]))
        precondition(callbackSheetRouter.selectedSheetDetent == .medium)
        callbackSheetRouter.selectSheetDetent(.large)
        precondition(callbackSheetRouter.selectedSheetDetent == .medium, "Invalid detent accepted")
        callbackSheetRouter.updateSheet(SheetConfiguration(detents: []))
        precondition(callbackSheetRouter.selectedSheetDetent == .medium)
        callbackSheetRouter.navigate(to: .home)
        callbackSheetRouter.navigate(to: detail)
        precondition(callbackSheetRouter.canGoBack(2) && !callbackSheetRouter.canGoBack(3))
        callbackSheetRouter.goBack(0)
        callbackSheetRouter.goBack(-1)
        callbackSheetRouter.goBack(3)
        precondition(callbackSheet.path.count == 2)
        callbackSheetRouter.goBack(2)
        precondition(callbackSheet.path.isEmpty)
        callbackSheetRouter.navigate(to: detail)
        callbackSheetRouter.reset()
        precondition(callbackSheet.path.isEmpty && callbackRoot.sheet === callbackSheet)
        callbackRoot.sheet = nil // Native interactive dismissal updates the item binding.
        callbackSheetRouter.dismiss() // A late duplicate must not fire twice.
        precondition(callbacks.isEmpty)
        callbackRouter.navigate(to: .home, .modal)
        precondition(callbackRoot.modal == nil, "Presented again before dismiss animation completed")
        callbackRoot.presentationDidDismiss(.sheet)
        callbackRoot.presentationDidDismiss(.sheet)
        precondition(callbacks == ["sheet"] && callbackRoot.modal != nil)
        callbackNav.router(for: callbackRoot.modal!).dismiss()
        callbackRoot.presentationDidDismiss(.modal)
        callbackRouter.navigate(to: .home, .sheet, onDismiss: { callbacks.append("parent") })
        let parent = callbackRoot.sheet!
        callbackNav.router(for: parent).navigate(to: .home, .modal, onDismiss: { callbacks.append("child") })
        callbackNav.router(for: parent).dismiss()
        callbackRoot.presentationDidDismiss(.sheet)
        precondition(callbacks.suffix(2) == ["child", "parent"])
        callbackRouter.navigate(to: .home, .sheet, onDismiss: { callbacks.append("replaced") })
        let replaced = callbackRoot.sheet!
        callbackRouter.navigate(to: .home, .asRoot)
        replaced.finishDismissal()
        precondition(callbacks.filter { $0 == "replaced" }.count == 1)
        let freshRouter = callbackNav.router(for: callbackNav.root)
        freshRouter.navigate(to: .home, .fadeCover, onDismiss: { callbacks.append("fade") })
        callbackNav.router(for: callbackNav.root.fadeCover!).dismiss()
        callbackNav.root.presentationDidDismiss(.fadeCover)
        callbackNav.root.presentationDidDismiss(.fadeCover)
        precondition(callbacks.filter { $0 == "fade" }.count == 1)

        var resolutions = 0
        let screenFactory = ScreenDIFactory(makeLoadHomePosts: {
            resolutions += 1
            return FixtureUseCase(posts: [post])
        })
        let firstScreen = screenFactory.makeHomeContainer()
        let secondScreen = screenFactory.makeHomeContainer()
        precondition(firstScreen !== secondScreen && resolutions == 2)
        precondition(!firstScreen.state.hasLoaded && !secondScreen.state.hasLoaded)

        // Secure storage uses isolated in-memory doubles; no developer credentials are read.
        let secure = MemorySecureStorage()
        let legacy = MemoryDefaults()
        legacy.set("fixture-access", forKey: "network.accessToken")
        legacy.set("fixture-refresh", forKey: "network.refreshToken")
        let tokens = TokenStore(storage: secure, legacyDefaults: legacy)
        secure.failsWrite = true
        precondition(tokens.accessToken == nil)
        precondition(legacy.string(forKey: "network.accessToken") != nil, "Failed migration deleted legacy credentials")
        secure.failsWrite = false
        precondition(tokens.accessToken == "fixture-access" && tokens.refreshToken == "fixture-refresh")
        precondition(legacy.string(forKey: "network.accessToken") == nil && legacy.string(forKey: "network.refreshToken") == nil)
        try! tokens.save(accessToken: "next", refreshToken: nil)
        let storedPair = try! JSONDecoder().decode(StoredTokens.self, from: secure.data!)
        precondition(storedPair.accessToken == "next" && storedPair.refreshToken == nil)
        secure.failsWrite = true
        do {
            try tokens.save(accessToken: "not persisted", refreshToken: "not persisted")
            preconditionFailure("Save failure must propagate")
        } catch {}
        secure.failsWrite = false
        precondition(tokens.accessToken == "next")
        secure.failsRead = true
        precondition(tokens.accessToken == nil)
        secure.failsRead = false
        legacy.set("stale", forKey: "network.accessToken")
        precondition(tokens.accessToken == "next" && legacy.string(forKey: "network.accessToken") == nil)
        secure.failsDelete = true
        do { try tokens.clear(); preconditionFailure("Delete failure must propagate") } catch {}
        precondition(tokens.accessToken == nil && tokens.refreshToken == nil, "Failed logout exposed old credentials")
        secure.failsDelete = false
        precondition(tokens.accessToken == nil && secure.data == nil)
        try! tokens.save(accessToken: "saved", refreshToken: "saved")
        try! tokens.save(accessToken: nil, refreshToken: nil)
        precondition(secure.data == nil)
        secure.data = Data("malformed".utf8)
        legacy.set("must not resurrect", forKey: "network.accessToken")
        precondition(tokens.accessToken == nil && secure.data == Data("malformed".utf8))
        print("Stability: queued send, lifecycle cancellation, dismissal completion, detents/back, DI, secure token migration PASSED")

        print("ProjMaker behavior: effects, Domain/use case, Home, nested navigation, dismiss/back, root replacement PASSED")

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
        mvi = ROOT / 'BaseSwiftUI/Core/Container'
        files = [mvi / name for name in ['DefaultInitializable.swift', 'MVIFeature.swift',
                                        'MVIContainer.swift', 'ContainerLifecycle.swift', 'BaseContainer.swift']]
        files += [ROOT / 'BaseSwiftUI' / path for path in [
            'Presentation/DataSource/Core/BaseDataSource.swift',
            'Core/Navigation/AppRoute.swift', 'Core/Navigation/NavigationConfig.swift',
            'Core/Navigation/AppNavigationState.swift',
            'Domain/Entities/Home/HomePost.swift', 'Domain/Repositories/HomePostRepository.swift',
            'Domain/UseCases/LoadHomePosts.swift', 'Presentation/Screens/Home/HomeItem.swift',
            'Presentation/Screens/Home/HomeContainer.swift',
            'Presentation/Screens/TranslationDemo/TranslationDemoContainer.swift',
            'Core/DI/ScreenDIFactory.swift', 'Presentation/Screens/Splash/SplashContainer.swift',
            'Presentation/Screens/WallpaperPaywall/WallpaperPaywallContainer.swift',
            'Presentation/Screens/WallpaperPaywall/WallpaperPaywallPlan.swift', 'Utils/AppInfo.swift',
            'Core/Network/Core/KeychainTokenStorage.swift', 'Core/Network/Core/TokenStore.swift',
            'Data/DTOs/Auth/StoredTokens.swift', 'Utils/Log.swift',
        ]]
        files.append(harness)
        subprocess.run(['xcrun', '--sdk', 'macosx', 'swiftc', '-swift-version', '5',
                        '-parse-as-library', '-module-cache-path', str(temp / 'cache'),
                        *map(str, files), '-o', str(temp / 'checks')], env=env, check=True)
        subprocess.run([str(temp / 'checks')], env=env, check=True, timeout=30)


if __name__ == '__main__':
    main()
