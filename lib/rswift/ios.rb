require 'rswift/shared'
Dir.glob(File.expand_path('ios/tasks/*.rake', File.dirname(__FILE__))).each { |r| load r}

module RSwift
  module IOS
  end
end
