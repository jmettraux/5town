
#
# Specifying 5town
#
# Thu Jan 14 08:15:48 JST 2021
#

require 'spec_helper'


describe 'make_creature' do

  it 'works with a centaur' do

	c = make_creature('sources/creatures/Centaur.md')
    s = c.to_md

    expect(s).to match(
      /\*\*Hit Dice\*\* 6 \(33 6d8\+6\)/)

    expect(s).to match(
      /\*\*\*Pike\.\*\*\* \+4 \(Stab 2 STR \+2\), .+ Hit: 1d10\+2/)
    expect(s).to match(
      /\*\*\*Hooves\.\*\*\* \+4 \(Stab 2 STR \+2\), .+ Hit: 2d6\+2/)
    expect(s).to match(
      /\*\*\*Longbow\.\*\*\* \+3 \(Shoot 2 DEX \+1\), .+ Hit: 1d8\+1/)
  end

  it 'works with a ghast' do

	c = make_creature('sources/creatures/Ghast.md')
    s = c.to_md

    expect(s).to match(
      /\*\*Hit Dice\*\* 8 \(36 8d8\)/)

    expect(s).to match(
      /\*\*\*Bite\.\*\*\* \+3 \(Stab 2 DEX \+1\), .+ Hit: 2d8\+1/)
    expect(s).to match(
      /\*\*\*Claws\.\*\*\* \+3 \(Stab 2 DEX \+1\), .+ Hit: 2d6\+1/)
  end

  it 'works with a goblin' do

	c = make_creature('sources/creatures/Goblin.md')
    s = c.to_md

    expect(s).to match(
      /\*\*Hit Dice\*\* 2 \(9 2d8\)/)

    expect(s).to match(
      /\*\*\*Scimitar\.\*\*\* \+3 \(Stab 2 DEX \+1\), .+ Hit: 1d6\+1/)
    expect(s).to match(
      /\*\*\*Shortbow\.\*\*\* \+3 \(Shoot 2 DEX \+1\), .+ Hit: 1d6\+1/)
  end
end

