
LI=-Ilib -rfivetown

goblin:
	ruby ${LI} -e "make_monster('sources/monsters/Goblin.md')"

monsters:
	ruby ${LI} -e "make_monsters"

