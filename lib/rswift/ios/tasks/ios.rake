require 'rake'
require 'rswift'

DERIVED_DATA_PATH = 'build'
DEFAULT_DEVICE_NAME = 'iPhone 6s'
DEVICE_NAME_ENV_KEY = 'device_name'
DEBUG_ENV_KEY = 'debug'

device_name = ENV[DEVICE_NAME_ENV_KEY]
device_name ||= DEFAULT_DEVICE_NAME
debug = ENV[DEBUG_ENV_KEY]
debug ||= '0'

workspace = RSwift::WorkspaceProvider.workspace
project = Xcodeproj::Project.open(Dir.glob('*.xcodeproj').first)
device_udid = RSwift::DeviceProvider.udid_for_device(device_name, :ios)

desc 'Build everything'
task :build do
  output = ""
  IO.popen("xcodebuild -workspace #{workspace} -scheme #{project.app_scheme_name} -destination 'platform=iphonesimulator,id=#{device_udid}' -derivedDataPath #{DERIVED_DATA_PATH} | xcpretty").each do |line|
    puts line.chomp
    output << line.chomp
  end
  success = output.include? "Build Succeeded"
  abort unless success

  IO.popen("xcodebuild -workspace #{workspace} -scheme #{project.app_scheme_name} -destination 'generic/platform=iphoneos' -derivedDataPath '#{DERIVED_DATA_PATH}' | xcpretty").each do |line|
    puts line.chomp
    output << line.chomp
  end
  success = output.include? "Build Succeeded"
  abort unless success
end

namespace :build do

  desc 'Build simulator version'
  task :simulator do
    output = ""
    IO.popen("xcodebuild -workspace #{workspace} -scheme #{project.app_scheme_name} -destination 'platform=iphonesimulator,id=#{device_udid}' -derivedDataPath #{DERIVED_DATA_PATH} | xcpretty").each do |line|
      puts line.chomp
      output << line.chomp
    end
    success = output.include? "Build Succeeded"
    abort unless success
  end

  desc 'Build device version'
  task :device do
    output = ""
    IO.popen("xcodebuild -workspace #{workspace} -scheme #{project.app_scheme_name} -destination 'generic/platform=iphoneos' -derivedDataPath '#{DERIVED_DATA_PATH}' | xcpretty").each do |line|
      puts line.chomp
      output << line.chomp
    end
    success = output.include? "Build Succeeded"
    abort unless success
  end
end

task :default => :simulator

desc 'Run the simulator'
task :simulator => :'build:simulator' do
  system "xcrun instruments -w #{device_udid}"
  system "xcrun simctl install booted #{DERIVED_DATA_PATH}/Build/Products/#{project.debug_build_configuration.name}-iphonesimulator/#{project.app_target.product_name}.app"
  system "xcrun simctl launch booted #{project.app_target.debug_product_bundle_identifier}"
  if debug.to_i.nonzero?
    exec "lldb -n #{project.app_target.product_name}"
  else
    exec "tail -f ~/Library/Logs/CoreSimulator/#{device_udid}/system.log"
  end
end

desc 'Deploy on the device'
task :device => :'build:device' do
  if debug.to_i.nonzero?
    exec "node_modules/.bin/ios-deploy --debug --bundle #{DERIVED_DATA_PATH}/Build/Products/#{project.debug_build_configuration.name}-iphoneos/#{project.app_scheme_name}.app"
  else
    exec "node_modules/.bin/ios-deploy --bundle #{DERIVED_DATA_PATH}/Build/Products/#{project.debug_build_configuration.name}-iphoneos/#{project.app_scheme_name}.app"
  end
end

desc 'Run the test/spec suite on the simulator'
task :spec do
  exec "xcodebuild test -workspace #{workspace} -scheme #{project.app_scheme_name} -destination 'platform=iphonesimulator,id=#{device_udid}' -derivedDataPath #{DERIVED_DATA_PATH} | xcpretty -tc"
end

namespace :simulator do

  desc 'Clean all simulators'
  task :clean do
    system 'killall Simulator'
    system 'xcrun simctl erase all'
  end
end
