require 'mongoid/alize/errors/alize_error'
require 'mongoid/alize/errors/invalid_field'

require 'mongoid/alize/callback'

require 'mongoid/alize/from_callback.rb'
require 'mongoid/alize/to_callback.rb'
require 'mongoid/alize/to_one_callback.rb'
require 'mongoid/alize/to_many_callback.rb'

require 'mongoid/alize/callbacks/from/one.rb'
require 'mongoid/alize/callbacks/from/many.rb'

require 'mongoid/alize/callbacks/to/one_from_one.rb'
require 'mongoid/alize/callbacks/to/one_from_many.rb'
require 'mongoid/alize/callbacks/to/many_from_one.rb'
require 'mongoid/alize/callbacks/to/many_from_many.rb'

require 'mongoid/alize/macros'

I18n.load_path << File.join(File.dirname(__FILE__), "..", "config", "locales", "en.yml")

module Mongoid
  module Alize
    extend ActiveSupport::Concern

    included do
      extend Mongoid::Alize::Macros
    end
  end
end
