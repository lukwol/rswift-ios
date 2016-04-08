# RSwift::IOS

RSwift::IOS lets you execute rake commands specific to iOS project.

RSwift::IOS uses rswift and rswift-shared gems.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rswift-ios'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rswift-ios

## Usage

Add this line to `Rakefile` in project directory

```ruby
require 'rswift/ios'
```

By default rswift will find project settings on it's own.
Group names and configurations have default initial values.
If you use custom configuration create `.rswift.yml` to specify different project settings.

```yml
app_scheme_name: MyApp
product_name: MyApp
app_group: MyApp                                    #Default: app
spec_group: MyAppSpec                               #Default: spec
debug_build_configuration: Debug                    #Default: Debug
release_build_configuration: Release                #Default: Release
debug_product_bundle_identifier: co.rswift.myapp
release_product_bundle_identifier: co.rswift.myapp
```

To display all tasks simply run `rake -T`

### Available tasks

```
rake clean              # Clean build objects
rake device             # Deploy on the device
rake device:build       # Build for device
rake pod:clean          # Clean cocoapods
rake simulator          # Run the simulator
rake simulator:build    # Build for simulator
rake simulator:clean    # Clean all simulators
rake spec               # Run the test/spec suite on the simulator
rake update:references  # Update file references
```

Default task is `rake simulator`

To select simulator for tasks `rake simulator` and `rake spec` set device_name, for example `device_name='iPad Air 2'`.

Additionaly tasks `rake simulator` and `rake device` can be executed with flag `debug=1`, which enables LLDB.

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lukwol/rswift-ios.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

