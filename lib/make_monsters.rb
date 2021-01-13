
class Monster

  attr_accessor :name, :type

  def to_md

    # TODO
  end
end

class MdownToMonster < Redcarpet::Render::Base

  attr_reader :monster

  def initialize
    super
    @monster = Monster.new
  end

  def normal_text(text); text; end

  def header(title, level)

    if level == 1
      @monster.name = title
    else
    end
  end

  def double_emphasis(text)
    "**#{text}**"
  end
  def emphasis(text)
p text
    if text.match?(/\A\*.+\*\z/)
      text
    elsif @monster.type == nil
      @monster.type = text
    else
    end
  end
  def paragraph(text)
  end
end

def make_monster(pa)

  s = File.read(pa)
puts "-" * 80; puts s.strip + "\n"; puts "-" * 80
  mtm = MdownToMonster.new

  Redcarpet::Markdown.new(mtm, tables: true).render(s)
  m = mtm.monster

  p m
end

def make_monsters


  Dir[File.join(__dir__, '../sources/monsters/*.md')].each do |pa|

    make_monster(pa)
  end
end

