
#
# Specifying 5town
#
# Thu Jan 14 08:15:48 JST 2021
#

require 'spec_helper'


describe 'make_creature' do

  it 'works with a goblin' do

	c = make_creature('sources/creatures/Goblin.md')
    s = c.to_md

puts s
    expect(s).to match(/ \+3 \(Stab 2 DEX \+1\),/)
  end
end

