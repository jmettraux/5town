
class Monster

  attr_accessor :phase, :name, :type

  def initialize

    @phase = 'Stats'
    @entries = {}
  end

  def <<(kv)

    (@entries[@phase] ||= []) << kv
  end

  def to_md

    # TODO
  end

  def to_h

    { name: @name,
      type: @type,
      entries: @entries }
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
#p [ :header, title, level ]
      @monster.phase = title
      ''
    end
  end

  def double_emphasis(text)

    "**#{text}**"
  end

  def emphasis(text)

#p text
    if text.match?(/\A\*.+\*\z/)
      text
    elsif @monster.type == nil
      @monster.type = text
    else
p [ :emphasis, text ]
      text
    end
  end

  def paragraph(text)

    if m = text.match(/^\*\*([^*]+)\*\* (.*)$/)
      @monster << [ m[1], m[2] ]
      text
    else
p [ :paragraph, text ]
      text
    end
  end
end

def make_monster(pa)

  s = File.read(pa)
puts "-" * 80; puts s.strip + "\n"; puts "-" * 80
  mtm = MdownToMonster.new

  Redcarpet::Markdown.new(mtm, tables: true).render(s)
  m = mtm.monster

pp m.to_h
end

def make_monsters


  Dir[File.join(__dir__, '../sources/monsters/*.md')].each do |pa|

    make_monster(pa)
  end
end

