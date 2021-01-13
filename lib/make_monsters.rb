
class Monster

  attr_reader :abilities
  attr_accessor :phase, :name, :type

  def initialize

    @abilities = [] # STR, DEX, CON, INT, WIS, CHA
    @phase = 'Stats'
    @entries = {}
  end

  def <<(kv)

    (@entries[@phase] ||= []) << kv
  end

  def to_h

    { name: @name, type: @type, abilities: @abilities, entries: @entries }
  end

  def to_md(opts={})

    @options = opts

    o = StringIO.new

    nn = "\n\n"

    o << '## ' << @name << nn
    o << '*' << @type << '*' << nn
    o << '**Hit Dice** ' << hit_dice << nn
    o << '**Armor Class** ' << armor_class << nn
    o << attribute_table << nn
    o << '**Saves** ' << saves << nn
    o << '**Skills** ' << skills << nn
    o << '**Move** ' << move << nn
    o << '**Morale** ' << morale << nn

    o.string
  end

  def hit_dice

    hp = self['Hit Points']
    m = hp.match(/\(([^)]+)d.+\)/)
    m ? m[1].to_i : 1
  end

  def armor_class

    self['Armor Class']
  end

  def saves

    [ 'Physical', save(:str, :con),
      'Evasion', save(:int, :dex),
      'Mental', save(:wis, :cha),
      'Luck', 15 ]
        .collect(&:to_s)
        .each_slice(2)
        .collect { |k, v| [ k, v ].join(' ') }
        .join(', ')
  end

  def skills

    ''
  end

  def move

    self['Speed']
  end

  def morale

    self['Morale']
  end

  def [](k)

    @entries.each do |_, a|
      v = a.assoc(k)
      return v.last if v
    end

    nil
  end

  protected

  def attribute_table

    %{
| STR     | DEX     | CON     | INT     | WIS     | CHA     |
|---------|---------|---------|---------|---------|---------|
    }.strip + "\n| " +
    [ acl(:str), acl(:dex), acl(:con), acl(:int), acl(:wis), acl(:cha) ]
      .join(' | ') +
    ' |'
  end

  def acl(att)

    m = modifier(att); m = "+#{m}" if m > -1
    s = "#{attribute(att)} (#{m})"
    s.length < 7 ? ' ' + s : s
  end

  def save(att0, att1)

    m = [ modifier(att0), modifier(att1) ].max

    if @options[:clasave]
      16 - hit_dice - m
    else
      15 - m
    end
  end

  def modifier(att)

    if @options[:att3]
      -4
    else
      case attribute(att)
      when 0...4 then -2
      when 4...8 then -1
      when 8...14 then 0
      when 14...18 then 1
      else 2
      end
    end
  end

  def attribute(att)

    v =
      case att.to_s
      when /str/i then @abilities[0]
      when /dex/i then @abilities[1]
      when /con/i then @abilities[2]
      when /int/i then @abilities[3]
      when /wis/i then @abilities[4]
      when /cha/i then @abilities[5]
      else 0
      end
    v.match(/\A(\d+)/)[1].to_i
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

    if text.match?(/\A\*.+\*\z/)
      text
    elsif @monster.type == nil
      @monster.type = text
    elsif text.match(/\A\*\*[A-Z]/)
      text.gsub(/\.$/, '')
    else
#p [ :emphasis, text ]
      text
    end
  end

  def paragraph(text)

    if m = text.match(/^\*\*([^*]+)\*\* (.*)$/)
      @monster << [ m[1], m[2] ]
      text
    else
#p [ :paragraph, text ]
      text
    end
  end

  def table(header, body); ''; end
  def table_row(content); ''; end
    #
  def table_cell(content, alignment)
    @monster.abilities << content if content.match(/\d+/)
    ''
  end
end

def make_monster(pa)

  s = File.read(pa)
puts "-" * 80; puts s.strip + "\n"; puts "-" * 80
  mtm = MdownToMonster.new

  Redcarpet::Markdown.new(mtm, tables: true).render(s)
  m = mtm.monster

pp m.to_h
puts "v" * 80
#puts m.to_md(clasave: true)
puts m.to_md
puts "^" * 80
end

def make_monsters


  Dir[File.join(__dir__, '../sources/monsters/*.md')].each do |pa|

    make_monster(pa)
  end
end

