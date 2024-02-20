require 'active_support/configurable'

module Mongoid
  module Alize
    include ActiveSupport::Configurable

    config_accessor :unscoped do
      false
    end

    class << self
      def setup
        yield config
      end
    end
  end
end