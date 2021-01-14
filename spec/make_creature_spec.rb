
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
      "reach 5ft_1.5m_1sq_+1, ",

    "**Speed** 40 ft." =>
      "**Speed** 40ft_12m_8sq_F",

    "**Move** 0 ft., fly 60 ft. (hover)" =>
      "**Move** 0ft, fly 60ft_18m_12sq_Ft-2 (hover)",

    '5ft' => '5ft_1.5m_1sq_+1',
    '10ft' => '10ft_3m_2sq_+2',
    '20ft' => '20ft_6m_4sq_t-2',
    '25ft' => '25ft_7.5m_5sq_t-1',
    '30ft' => '30ft_9m_6sq_t',
    '35ft' => '35ft_10.5m_7sq_F-1',
    '40ft' => '40ft_12m_8sq_F',
    '70ft' => '70ft_21m_14sq_Ft',
    '80ft' => '80ft_24m_16sq_FF',
    '100ft' => '100ft_30m_20sq_FFt-2',

  }.each do |k, v|

    it "turns #{k.inspect} into #{v.inspect}" do

      expect(expand_ranges(k)).to eq(v)
    end
  end
end

