
RUBY=bundle exec ruby
LI=-Ilib -rfivetown


gob:
	${RUBY} ${LI} -e "puts make_creature('sources/creatures/Goblin.md').to_md"
cen:
	${RUBY} ${LI} -e "puts make_creature('sources/creatures/Centaur.md').to_md"
gha:
	${RUBY} ${LI} -e "puts make_creature('sources/creatures/Ghast.md').to_md"
orc:
	${RUBY} ${LI} -e "puts make_creature('sources/creatures/Orc.md').to_md"

creatures:
	${RUBY} ${LI} -e "make_creatures"
all: creatures

