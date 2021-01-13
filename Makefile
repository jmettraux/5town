
RUBY=bundle exec ruby
LI=-Ilib -rfivetown


goblin:
	${RUBY} ${LI} -e "puts make_creature('sources/creatures/Goblin.md').to_md"
gob: goblin

creatures:
	${RUBY} ${LI} -e "make_creatures"
all: creatures

