
RUBY=bundle exec ruby
LI=-Ilib -rfivetown


gob:
	${RUBY} ${LI} -e "compare_creature('sources/creatures/Goblin.md')"
frog:
	${RUBY} ${LI} -e "compare_creature('sources/creatures/Frog.md')"
dbar:
	${RUBY} ${LI} -e "compare_creature('sources/creatures/Devil__Barbed.md')"
cen:
	${RUBY} ${LI} -e "compare_creature('sources/creatures/Centaur.md')"
gha:
	${RUBY} ${LI} -e "compare_creature('sources/creatures/Ghast.md')"
orc:
	${RUBY} ${LI} -e "compare_creature('sources/creatures/Orc.md')"

creatures:
	${RUBY} ${LI} -e "make_creatures"
all: creatures

weapons:
	${RUBY} ${LI} -e "list_weapons"

feet:
	${RUBY} ${LI} -e "FeetExpander.list_csv_to(300)"

