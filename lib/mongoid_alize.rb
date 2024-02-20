require 'mongoid/alize/config'

require 'mongoid/alize/errors/alize_error'
require 'mongoid/alize/errors/invalid_field'
require 'mongoid/alize/errors/already_defined_field'
require 'mongoid/alize/errors/invalid_configuration'

require 'mongoid/alize/callback'

require 'mongoid/alize/from_callback.rb'
require 'mongoid/alize/to_callback.rb'

require 'mongoid/alize/callbacks/from/one.rb'
require 'mongoid/alize/callbacks/from/many.rb'

require 'mongoid/alize/macros'
require 'mongoid/alize/instance_helpers'

I18n.load_path << File.join(File.dirname(__FILE__), "..", "config", "locales", "en.yml")

module Mongoid
  module Alize
    extend ActiveSupport::Concern

    included do
      extend Mongoid::Alize::Macros
      include Mongoid::Alize::InstanceHelpers
    end
  end
end
