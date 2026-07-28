#!/usr/bin/env ruby

require "fileutils"
require "xcodeproj"

root = File.expand_path("..", __dir__)
project_path = File.join(root, "BaseSwiftUI.xcodeproj")
FileUtils.rm_rf(project_path)

project = Xcodeproj::Project.new(project_path)
project.root_object.development_region = "en"
project.root_object.known_regions = ["en", "Base"]

target = project.new_target(:application, "BaseSwiftUI", :ios, "17.0")
target.product_name = "BaseSwiftUI"

app_group = project.new(Xcodeproj::Project::Object::PBXFileSystemSynchronizedRootGroup)
app_group.path = "BaseSwiftUI"
app_group.source_tree = "<group>"
project.main_group.children.insert(0, app_group)
target.file_system_synchronized_groups << app_group

info_plist_exception = project.new(
  Xcodeproj::Project::Object::PBXFileSystemSynchronizedBuildFileExceptionSet
)
info_plist_exception.membership_exceptions = [
  "Resources/Info.plist",
  "Base/CoreData/README.md",
  "Base/Helpers/README.md",
  "Helper/README.md",
  "Libs/README.md",
  "MT-CleanArchitecture/README.md",
  "Utils/README.md",
  "Widgets/README.md"
]
info_plist_exception.target = target
app_group.exceptions << info_plist_exception

target.build_configurations.each do |configuration|
  settings = configuration.build_settings
  settings["ASSETCATALOG_COMPILER_APPICON_NAME"] = "AppIcon"
  settings["ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME"] = "AccentColor"
  settings["CODE_SIGN_STYLE"] = "Automatic"
  settings["CURRENT_PROJECT_VERSION"] = "1"
  settings["GENERATE_INFOPLIST_FILE"] = "NO"
  settings["INFOPLIST_FILE"] = "BaseSwiftUI/Resources/Info.plist"
  settings["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
  settings["MARKETING_VERSION"] = "1.0"
  settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.emoji.ai.maker.stickermaker"
  settings["PRODUCT_NAME"] = "$(TARGET_NAME)"
  settings["SWIFT_EMIT_LOC_STRINGS"] = "YES"
  settings["SWIFT_VERSION"] = "5.0"
  settings["TARGETED_DEVICE_FAMILY"] = "1,2"
end

project.build_configurations.each do |configuration|
  configuration.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "17.0"
end

project.save

scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(target)
scheme.set_launch_target(target)
scheme.save_as(project_path, "BaseSwiftUI", true)

puts "Generated #{project_path}"
