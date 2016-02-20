require 'spec_helper'

describe RSwift::IOS do

  describe 'default task' do

    before do
      @default_task = Rake::Task[:default]
    end

    describe 'prerequiste tasks' do

      before do
        @prerequisite_tasks = @default_task.prerequisites
      end

      it 'should have 1 prerequiste task' do
        expect(@prerequisite_tasks.count).to eq(1)
      end

      describe 'first task' do

        before do
          @prerequiste_task = @prerequisite_tasks[0]
        end

        it 'should be simulator task' do
          expect(@prerequiste_task).to eq('simulator')
        end
      end
    end
  end

  describe 'build task' do

    before do
      @build_task = Rake::Task[:build]
      allow(Dir).to receive(:glob).with('*.xcodeproj').and_return(['fixture.xcodeproj'])
      @spy_project = spy(app_scheme_name: 'fixtureAppScheme')
      allow(Xcodeproj::Project).to receive(:open).with('fixture.xcodeproj').and_return(@spy_project)
      allow_any_instance_of(Kernel).to receive(:system) { |_, command| @captured_command = command }
    end

    describe 'execute' do

      before do
        allow(RSwift::WorkspaceProvider).to receive(:workspace).and_return('fixture.xcworkspace')
      end

      context 'when user does not specify device name' do

        before do
          ENV['device_name'] = nil
          allow(RSwift::DeviceProvider).to receive(:udid_for_device).with('iPhone 6s', :ios).and_return('fixture_iphone_udid')
          @build_task.execute
        end

        it 'should build workspace for default device' do
          expected_command = "xcodebuild -workspace fixture.xcworkspace -scheme fixtureAppScheme -destination 'platform=iphonesimulator,id=fixture_iphone_udid' -derivedDataPath build | xcpretty"
          expect(@captured_command).to eq(expected_command)
        end
      end

      context 'when user specifies device name' do

        before do
          ENV['device_name'] = 'iPad Air 2'
          allow(RSwift::DeviceProvider).to receive(:udid_for_device).with('iPad Air 2', :ios).and_return('fixture_ipad_udid')
          @build_task.execute
        end

        it 'should build workspace for proper device' do
          expected_command = "xcodebuild -workspace fixture.xcworkspace -scheme fixtureAppScheme -destination 'platform=iphonesimulator,id=fixture_ipad_udid' -derivedDataPath build | xcpretty"
          expect(@captured_command).to eq(expected_command)
        end
      end
    end
  end

  describe 'simulator task' do

    before do
      @simulator_task = Rake::Task[:simulator]
    end

    describe 'prerequiste tasks' do

      before do
        @prerequisite_tasks = @simulator_task.prerequisites
      end

      it 'should have 1 prerequiste task' do
        expect(@prerequisite_tasks.count).to eq(1)
      end

      describe 'first prerequiste task' do

        before do
          @prerequiste_task = @prerequisite_tasks[0]
        end

        it 'should be build task' do
          expect(@prerequiste_task).to eq('build')
        end
      end
    end

    describe 'execute' do

      before do
        ENV['device_name'] = nil
        ENV['debug'] = '0'
        allow(RSwift::DeviceProvider).to receive(:udid_for_device).with('iPhone 6s', :ios).and_return('fixture_iphone_udid')
        @captured_commands = []
        allow(Dir).to receive(:glob).with('*.xcodeproj').and_return(['fixture.xcodeproj'])
        allow(Dir).to receive(:glob).with(['*.xcworkspace']).and_return(['fixture.xcworkspace'])
        @spy_app_target = spy(product_name: 'fixture_product_name', debug_product_bundle_identifier: 'fixture_debug_product_bundle_identifier')
        @spy_project = spy(app_target: @spy_app_target)
        allow(Xcodeproj::Project).to receive(:open).with('fixture.xcodeproj').and_return(@spy_project)
        allow_any_instance_of(Kernel).to receive(:system) { |_, command| @captured_commands << command }
        allow_any_instance_of(Kernel).to receive(:exec) { |_, command| @captured_commands << command }
        @simulator_task.clear_prerequisites
      end

      context 'when user does not specify device name' do

        before do
          @simulator_task.execute
        end

        describe 'executed commands' do

          it 'should execute 4 commands' do
            expect(@captured_commands.count).to eq(4)
          end

          describe 'first executed command' do

            before do
              @captured_command = @captured_commands[0]
            end

            it 'should run default device' do
              expected_command = 'xcrun instruments -w fixture_iphone_udid'
              expect(@captured_command).to eq(expected_command)
            end
          end

          describe 'second executed command' do

            before do
              @captured_command = @captured_commands[1]
            end

            it 'should install app on booted device' do
              expected_command = 'xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/fixture_product_name.app'
              expect(@captured_command).to eq(expected_command)
            end
          end

          describe 'third executed command' do

            before do
              @captured_command = @captured_commands[2]
            end

            it 'should lunch installed app on booted device' do
              expected_command = 'xcrun simctl launch booted fixture_debug_product_bundle_identifier'
              expect(@captured_command).to eq(expected_command)
            end
          end

          describe 'fourth executed command' do

            before do
              @captured_command = @captured_commands[3]
            end

            it 'should tail system log from simulator' do
              expected_command = 'tail -f ~/Library/Logs/CoreSimulator/fixture_iphone_udid/system.log'
              expect(@captured_command).to eq(expected_command)
            end
          end
        end
      end

      context 'when user specifies device name' do

        before do
          ENV['device_name'] = 'iPad Air 2'
          allow(RSwift::DeviceProvider).to receive(:udid_for_device).with('iPad Air 2', :ios).and_return('fixture_ipad_udid')
          @simulator_task.execute
        end

        describe 'executed commands' do

          it 'should execute 4 commands' do
            expect(@captured_commands.count).to eq(4)
          end

          describe 'first executed command' do

            before do
              @captured_command = @captured_commands[0]
            end

            it 'should run default device' do
              expected_command = 'xcrun instruments -w fixture_ipad_udid'
              expect(@captured_command).to eq(expected_command)
            end
          end

          describe 'fourth executed command' do

            before do
              @captured_command = @captured_commands[3]
            end

            it 'should tail system log from simulator' do
              expected_command = 'tail -f ~/Library/Logs/CoreSimulator/fixture_ipad_udid/system.log'
              expect(@captured_command).to eq(expected_command)
            end
          end
        end
      end

      context 'when user wants to debug application' do

        before do
          ENV['debug'] = '1'
          @simulator_task.execute
        end

        it 'should run lldb with proper app name' do
          expect(@captured_commands.last).to eq('lldb -n fixture_product_name')
        end
      end
    end
  end

  describe 'spec task' do

    before do
      @spec_task = Rake::Task[:spec]
      allow(Dir).to receive(:glob).with('*.xcodeproj').and_return(['fixture.xcodeproj'])
      @spy_project = spy(app_scheme_name: 'fixtureAppScheme')
      allow(Xcodeproj::Project).to receive(:open).with('fixture.xcodeproj').and_return(@spy_project)
      allow_any_instance_of(Kernel).to receive(:exec) { |_, command| @captured_command = command }
    end

    describe 'execute' do

      before do
        allow(RSwift::WorkspaceProvider).to receive(:workspace).and_return('fixture.xcworkspace')
      end

      context 'when user does not specify device name' do

        before do
          ENV['device_name'] = nil
          allow(RSwift::DeviceProvider).to receive(:udid_for_device).with('iPhone 6s', :ios).and_return('fixture_iphone_udid')
          @spec_task.execute
        end

        it 'should test workspace for default device' do
          expected_command = "xcodebuild test -workspace fixture.xcworkspace -scheme fixtureAppScheme -destination 'platform=iphonesimulator,id=fixture_iphone_udid' -derivedDataPath build | xcpretty -tc"
          expect(@captured_command).to eq(expected_command)
        end
      end

      context 'when user specifies device name' do

        before do
          ENV['device_name'] = 'iPad Air 2'
          allow(RSwift::DeviceProvider).to receive(:udid_for_device).with('iPad Air 2', :ios).and_return('fixture_ipad_udid')
          @spec_task.execute
        end

        it 'should test workspace for proper device' do
          expected_command = "xcodebuild test -workspace fixture.xcworkspace -scheme fixtureAppScheme -destination 'platform=iphonesimulator,id=fixture_ipad_udid' -derivedDataPath build | xcpretty -tc"
          expect(@captured_command).to eq(expected_command)
        end
      end
    end
  end
end
