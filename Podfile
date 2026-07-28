platform :ios, '17.0'

project 'BaseSwiftUI.xcodeproj'

target 'BaseSwiftUI' do
  use_frameworks!

  pod 'Alamofire', '5.12.0'
  pod 'Factory', '2.5.2'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
  end
end
