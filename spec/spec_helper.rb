
#
# Specifying 5town
#
# Thu Jan 14 08:14:50 JST 2021
#

require 'pp'

require 'fivetown'


module Helpers
end # Helpers


RSpec.configure do |c|

  c.alias_example_to(:they)
  c.alias_example_to(:so)
  c.include(Helpers)
end

