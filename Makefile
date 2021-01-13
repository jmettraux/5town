
LI=-Ilib -rfivetown

goblin:
	ruby ${LI} -e "puts make_creature('sources/creatures/Goblin.md').to_md"

creatures:
	ruby ${LI} -e "make_creatures"
all: creatures

