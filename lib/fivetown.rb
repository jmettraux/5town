
require 'redcarpet'


#module Fivetown; end

Dir[File.join(__dir__, '*.rb')]
  .each do |pa|

    next if %w[ fivetown.rb ].find { |e| pa.end_with?(e) }

    require(pa)
  end

#def neutralize_name(s); s.gsub(/[^a-zA-Z]/, '_'); end

