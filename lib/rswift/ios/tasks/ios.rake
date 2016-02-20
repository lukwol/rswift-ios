require 'rake'
require 'rswift'

DERIVED_DATA_PATH = 'build'
DEFAULT_DEVICE_NAME = 'iPhone 6s'
DEVICE_NAME_ENV_KEY = 'device_name'
DEBUG_ENV_KEY = 'debug'

task :default => :simulator

desc 'Build workspace'
task :build do
  device_name = ENV[DEVICE_NAME_ENV_KEY]
  device_name ||= DEFAULT_DEVICE_NAME
  workspace = RSwift::WorkspaceProvider.workspace
  project_path = Dir.glob('*.xcodeproj').first
  project = Xcodeproj::Project.open(project_path)
  device_udid = RSwift::DeviceProvider.udid_for_device(device_name, :ios)
  output = ""
  IO.popen("xcodebuild -workspace #{workspace} -scheme #{project.app_scheme_name} -destination 'platform=iphonesimulator,id=#{device_udid}' -derivedDataPath #{DERIVED_DATA_PATH} | xcpretty").each do |line|
    puts line.chomp
    output << line.chomp
  end
  success = output.include? "Build Succeeded"
  abort unless success
end

desc 'Run the simulator'
task :simulator => [:build] do
  device_name = ENV[DEVICE_NAME_ENV_KEY]
  device_name ||= DEFAULT_DEVICE_NAME
  debug = ENV[DEBUG_ENV_KEY]
  debug ||= '0'
  project_path = Dir.glob('*.xcodeproj').first
  project = Xcodeproj::Project.open(project_path)
  device_udid = RSwift::DeviceProvider.udid_for_device(device_name, :ios)
  system "xcrun instruments -w #{device_udid}"
  system "xcrun simctl install booted #{DERIVED_DATA_PATH}/Build/Products/Debug-iphonesimulator/#{project.app_target.product_name}.app"
  system "xcrun simctl launch booted #{project.app_target.debug_product_bundle_identifier}"
  if debug.to_i.nonzero?
    exec "lldb -n #{project.app_target.product_name}"
  else
    exec "tail -f ~/Library/Logs/CoreSimulator/#{device_udid}/system.log"
  end
end

desc 'Run the test/spec suite on the simulator'
task :spec do
  device_name = ENV[DEVICE_NAME_ENV_KEY]
  device_name ||= DEFAULT_DEVICE_NAME
  workspace = RSwift::WorkspaceProvider.workspace
  project_path = Dir.glob('*.xcodeproj').first
  project = Xcodeproj::Project.open(project_path)
  device_udid = RSwift::DeviceProvider.udid_for_device(device_name, :ios)
  exec "xcodebuild test -workspace #{workspace} -scheme #{project.app_scheme_name} -destination 'platform=iphonesimulator,id=#{device_udid}' -derivedDataPath #{DERIVED_DATA_PATH} | xcpretty -tc"
end

namespace :simulator do

  desc 'Clean all simulators'
  task :clean do
    system 'killall Simulator'
    system 'xcrun simctl erase all'
  end
end
