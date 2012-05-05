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

module Mongoid
  module Alize
    extend ActiveSupport::Concern

    included do
      extend Mongoid::Alize::Macros
    end
  end
end
