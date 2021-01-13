
LI=-Ilib -rfivetown

goblin:
	ruby ${LI} -e "make_creature('sources/creatures/Goblin.md')"

creatures:
	ruby ${LI} -e "make_creatures"

