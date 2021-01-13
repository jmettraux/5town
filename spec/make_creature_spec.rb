
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

#puts s
    expect(s).to match(/ \+3 \(Stab 2 DEX \+1\),/)
  end
end

describe 'expand_ranges' do

  {

    "reach 5 ft., " =>
      "reach 5ft_1.5m_1sq, ",

    "**Speed** 40 ft." =>
      "**Speed** 40ft_12m_8sq",

    "**Move** 0 ft., fly 60 ft. (hover)" =>
      "**Move** 0ft, fly 60ft_18m_12sq (hover)",


  }.each do |k, v|

    it "turns #{k.inspect} into #{v.inspect}" do

      expect(expand_ranges(k)).to eq(v)
    end
  end
end

