# Hướng CI cho BaseSwiftUI — đề xuất, chưa triển khai

Tài liệu này phục vụ lựa chọn hướng đi. Chưa thêm workflow build/test app,
target XCTest/UI test, runner, signing secret hay tự động phân phối ứng dụng.

## Mục tiêu nên chọn trước

Với một base tái sử dụng, CI nên trả lời: thay đổi này có làm hỏng khả năng
build, hành vi nền tảng hoặc tạo dự án mới không? Việc phát hành TestFlight
thuộc giai đoạn sau và có thể thuộc từng app được tạo từ base.

CI là quy trình kiểm tra tự động; GitHub Actions/Xcode Cloud là nơi chạy quy
trình. XCTest/XCUITest cung cấp các kiểm tra hành vi. Fastlane là công cụ đóng
gói các bước build/test/release, không phải dịch vụ thay thế CI và chưa bắt
buộc cho base nhỏ này.

## Các lựa chọn

| Hướng | Phù hợp khi | Điểm mạnh | Chi phí/công sức cần cân nhắc |
| --- | --- | --- | --- |
| GitHub Actions với runner macOS do GitHub quản lý | Code ở GitHub, muốn kiểm tra PR và giữ cấu hình trong repo | Chạy được cả Python validator, launcher checks, xcodebuild và test; dễ tái sử dụng cho app sinh từ template | Phải quản lý YAML, phiên bản Xcode/Ruby/CocoaPods và thời gian build; hạn mức phụ thuộc gói và loại repo |
| Xcode Cloud | Trọng tâm là app Apple, Xcode và TestFlight | Tích hợp với Xcode/App Store Connect, build/test/phân phối trong hệ sinh thái Apple | Cần thiết lập tài khoản/dự án tương ứng; CocoaPods cần bước chuẩn bị dependency; kiểm tra script đa nền tảng kém tự nhiên hơn một workflow tổng quát |
| Bitrise hoặc Codemagic | Muốn dịch vụ chuyên mobile với hỗ trợ signing/distribution và các bước dựng sẵn | Thuận tiện khi nhóm có nhiều app và muốn giảm công sức tự ghép các bước | Thêm dịch vụ, quyền truy cập repo, cấu hình riêng và ngân sách; cần đối chiếu gói hiện hành |
| GitHub Actions với Mac tự quản | Có Mac riêng luôn hoạt động và người bảo trì | Kiểm soát Xcode, cache, tài nguyên máy | Tốn máy/điện/bảo trì; máy offline làm hàng đợi đứng; cần cô lập runner khỏi máy làm việc và không chạy PR không tin cậy trên máy chứa credential |

Khuyến nghị ban đầu: **GitHub Actions với runner macOS do GitHub quản lý**.
Repo đã có Actions cho agent setup; hướng này mở rộng được sang app mà không
phải đưa toàn bộ dự án sang dịch vụ khác. Chưa có lý do đủ mạnh để bắt đầu
bằng Mac tự quản hoặc triển khai đồng thời nhiều nền tảng CI.

Theo tài liệu billing GitHub hiện tại, standard hosted runners cho repo public
được miễn phí; larger runners vẫn tính phí. Repo private dùng hạn mức compute
và storage theo gói rồi có thể phát sinh phí. Vì vậy public/private là thông
tin quan trọng cần chốt trước khi dự toán; runner macOS có đơn giá khác Linux.

Nếu mục tiêu chính chuyển sang TestFlight và nhóm đã sử dụng Apple Developer
Program, Xcode Cloud là lựa chọn đáng so sánh. Apple hiện công bố 25 compute
hours/tháng đi kèm membership; kiểm tra lại trang chính thức trước khi chọn
gói. Không chốt ngân sách chỉ từ con số miễn phí: số PR, thời gian build và
số cấu hình test mới quyết định mức sử dụng thực tế.

## Lộ trình triển khai khi đã thống nhất

### Bước 1 — Build ổn định và kiểm tra nhanh

- Giữ validator agent/skill trên Linux.
- Job macOS riêng: chọn Xcode có SDK hỗ trợ mã iOS 26 hiện có, cài Pods, chạy
  build Debug qua `BaseSwiftUI.xcworkspace`, đích `generic/platform=iOS`,
  `CODE_SIGNING_ALLOWED=NO`. iOS deployment target vẫn là 17.
- Chạy các regression script hiện có nếu phù hợp; chưa cần tạo target test
  chỉ để có một job màu xanh.
- Lưu log khi lỗi, đặt timeout và hủy run cũ của cùng PR khi có commit mới.
- Trigger theo source/project/dependency/scripts liên quan. Nếu dùng required
  checks, thiết kế job tổng kết luôn trả trạng thái để path filter không làm
  PR chờ vô hạn vì check không được tạo.
- Đánh giá runner image/Xcode thực tế trước khi chọn nhãn cụ thể; không dùng
  `latest` mà bỏ qua khả năng đổi toolchain ngoài ý muốn.

Trước khi làm bước này cần chốt dependency reproducibility: `Podfile` đã pin
hai dependency trực tiếp, nhưng `.gitignore` hiện bỏ qua `Podfile.lock` và
chưa có Gemfile pin CocoaPods. Cân nhắc commit lockfile cho base và pin công cụ
bằng Bundler. Đây là thay đổi riêng cần thống nhất; chưa thực hiện ở lượt này.
Cache dựa trên lockfile/toolchain chỉ tăng tốc, không được thay thế bước xác
nhận dependency hay che lỗi build sạch.

### Bước 2 — Kiểm tra hành vi nền tảng

- Thêm target unit test khi thống nhất phạm vi kiểm thử.
- Ưu tiên: cancellation/loading, identity sau reorder/remove, Home
  success/error/empty/retry, policy refresh 401 và route state.
- Dùng fake repository/use case và stub networking; không gọi API công khai
  trong các kiểm tra quyết định PR pass/fail.
- Chạy bằng Simulator trên một cấu hình cố định mà runner hỗ trợ; thêm ma
  trận nhiều iOS chỉ khi có nhu cầu tương thích và ngân sách rõ ràng.
- Thu `.xcresult`; chỉ đặt ngưỡng coverage khi đã có baseline đáng tin.

### Bước 3 — Kiểm tra UI và khả năng sinh dự án

- Một số smoke test: mở Home, lỗi/thử lại, chọn item, Back; sau đó sheet/dismiss.
- Kiểm tra chữ lớn, nội dung dài và accessibility theo màn hình quan trọng;
  không xem build thành công là bằng chứng UI đúng.
- Tạo dự án vào thư mục tạm cô lập từ snapshot rồi build để phát hiện lỗi
  rename, scheme, workspace, Pods hoặc file mới không được copy.
- Chạy những job tốn thời gian theo lịch hoặc trước release template trước
  khi đưa tất cả vào mỗi PR.

### Bước 4 — Phân phối, nếu cần

Chỉ sau khi CI build/test ổn định mới thêm archive, signing, TestFlight và
quyền App Store Connect. Tách job phát hành khỏi kiểm tra PR; không cấp signing
secret cho build không tin cậy. Base template có thể chỉ cần CI; các app sinh
ra mới cần CD. Không cần giải quyết cả hai ngay từ đầu.

## Tiêu chí đánh giá một lần thử

Đo thời gian build sạch và có cache, số phút chạy mỗi tuần, tỷ lệ lỗi môi
trường/flaky, độ rõ của log và khả năng bắt một lỗi được cố tình đưa vào nhánh
thử nghiệm. Sau một khoảng thử đủ đại diện, mới bật required checks và quyết
định có cần thêm dịch vụ hoặc runner mạnh hơn.

CI chỉ chạy kiểm tra; không tự chứng minh thiết kế đúng hoặc tự sửa toàn bộ
bug. Một pipeline ngắn, ổn định và bắt được lỗi thật có giá trị hơn nhiều job
không rõ mục tiêu.

## Thông tin cần chốt trước khi triển khai

1. Repo public hay private, GitHub plan và ngân sách hàng tháng?
2. Chỉ kiểm tra PR hay cần TestFlight cho app cụ thể?
3. Có Apple Developer Program và nhóm bao nhiêu người/app?
4. Muốn thời gian chờ PR tối đa bao lâu, số PR mỗi tuần khoảng bao nhiêu?

## Nguồn chính thức để bắt đầu

- [GitHub-hosted runners](https://docs.github.com/en/actions/concepts/runners/github-hosted-runners)
- [GitHub Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions)
- [Runner images và danh sách phần mềm/Xcode](https://github.com/actions/runner-images)
- [Xcode Cloud](https://developer.apple.com/xcode-cloud/)
- [Bitrise: Getting started with iOS apps](https://docs.bitrise.io/en/getting-started/quick-start-guides/getting-started-with-ios-apps.html)
- [Codemagic: Building a native iOS app](https://docs.codemagic.io/yaml-quick-start/building-a-native-ios-app/)

Ưu tiên tài liệu của nhà cung cấp và danh sách phần mềm trên runner khi áp
dụng hướng dẫn. Các bài blog có thể dùng Xcode/runner/signing đã cũ. Giá và
hạn mức phải được đối chiếu lại tại thời điểm thực sự triển khai.
