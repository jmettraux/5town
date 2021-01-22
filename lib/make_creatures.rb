
#
# expand_ranges


#
# Creature class

class Creature

  attr_reader :abilities
  attr_accessor :phase, :name, :type

  def initialize

    @abilities = [] # STR, DEX, CON, INT, WIS, CHA
    @phase = 'Stats'
    @entries = {}

    @stab = nil
    @shoot = nil
  end

  def <<(kv)

    k, v = kv

    (@entries[@phase] ||= []) << [ k.gsub('.', ''), v ]
  end

  def to_h

    { name: @name, type: @type, abilities: @abilities, entries: @entries }
  end

  def to_md(opts={})

    @options = opts

    @entries['Actions'].each { |a| translate_action(a) }
    attacks = @entries['Actions'].collect { |a| translate_action(a) }.flatten
      # 1st pass, then second pass...
      # which sets Stab and Shoot

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

    o << '## Attacks' << nn
    attacks.each { |a| o << a << nn }

    o.string
  end

  def hdice

    hp = self['Hit Points']
    m = hp.match(/\(([^)]+)d.+\)/)
    m ? m[1].to_i : 1
  end

  def hit_dice

    hd = hdice

    con = hd * modifier(:con)

    hdd = "#{hd}d8"
    hdd = hdd + ((con < 0) ? "-#{con}" : (con > 0) ? "+#{con}" : '')

    hps = (hd * 4.5).to_i + con

    "#{hd} (#{hps} #{hdd})"
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

    a = []

    a << [ "Stab #{@stab.first}" ] if @stab
    a << [ "Shoot #{@shoot.first}" ] if @shoot

    a.concat(
      (self['Skills'] || '')
        .split(/\s*,\s*/).collect { |s| translate_skill(s) })

    a.join(', ')
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

  SKILL_TO_ATT = {

    'Athletics' => :str,

    'Acrobatics' => :dex, 'Sleight of hand' => :dex, 'Stealth' => :dex,

    'Arcana' => :int, 'History' => :int, 'Investigation' => :int,
    'Nature' => :int, 'Religion' => :int,

    'Animal Handling' => :wis, 'Insight' => :wis, 'Medicine' => :wis,
    'Perception' => :wis, 'Survival' => :wis,

    'Deception' => :cha, 'Intimidation' => :cha, 'Performance' => :cha,
    'Persuasion' => :cha

      }.freeze

  SKILL_TO_SKILL = {
    'Athletics' => 'Exert (str)',
    'Acrobatics' => 'Exert (dex)',
    'Sleight of hand' => 'Perform',
    'Stealth' => 'Sneak',
    'Arcana' => 'Magic',
    'History' => 'Know',
    'Investigation' => 'Connect',
    'Nature' => 'Survive',
    'Religion' => 'Pray',
    'Animal Handling' => 'Ride',
    'Insight' => 'Notice',
    'Medicine' => 'Heal',
    'Perception' => 'Notice',
    'Survival' => 'Survive',
    'Deception' => 'Connect',
    'Intimidation' => 'Lead',
    'Performance' => 'Perform',
    'Persuasion' => 'Convice'
      }.freeze

  # Punch / Smite (WOG)
  # Stab / Spear (WOG)
  # Shoot
    #
  # Administer / Reeve (WOG)
  # Connect
  # Convince / Talk (WOG)
  # Craft
  # Exert
  # Heal
  # Know / Ken (WOG)
  # Lead
  # Magic
  # Notice
  # Perform
  # Pray
  # Ride
  # Sail
  # Sneak
  # Survive / Hunt (WOG)
  # Work / Toil (WOG)
  # Trade / Gift (WOG)

  def translate_skill(s)

    m = s.match(/\A([^-+]+) ([-+]\d+)/)
    n = m[1]
    n1 = SKILL_TO_SKILL[n]
    b = m[2].to_i
    a = SKILL_TO_ATT[n]
    m5 = mod5(a)

    sl = b - m5
    if sl < 1 then sl = 0
    else sl = sl / 2
    end

    "#{n1} #{sl}"
  end

  def translate_action(a)

    name, desc = a

    r = [
      do_translate_action('Stab', name, desc),
      do_translate_action('Shoot', name, desc)
        ].compact

    r.any? ? r : [ "***#{name}.*** #{desc}" ]
  end

  def do_translate_action(type, name, desc)

    return nil if type == 'Stab' && ! desc.match?(/melee .+ attack:/i)
    return nil if type == 'Shoot' && ! desc.match?(/ranged .+ attack:/i)

    desc1 = desc
      .gsub(/^(Melee|Ranged|Melee or Ranged) Weapon Attack:/,
        '')
      .gsub(/ ([-+]\d+) to hit/) { |m|
        translate_attack_mod(type, $1.to_i) }
      .gsub(/ Hit: \d+ \(([^)]+)\) /) { |m|
        translate_attack_damage(type, $1) }

    desc1 = type == 'Stab' ?
      desc1.gsub(/ (or )?range [^,$]+/, '') :
      desc1.gsub(/reach (?:(?!, |or ).)+(, |or )/, '')

    "***#{name}.*** #{desc1}"
  end

  # Warning: sets @stab or @shoot
  #
  def translate_attack_mod(type, bonus)

    ab = (hdice.to_f / 2.0).floor
#p [ hit_dice, ab ]

    m5s, m5d = mod5(:str), mod5(:dex)
    d5s, d5d = bonus - m5s, bonus - m5d

    att = d5s < d5d ? :str : :dex
    rem = [ d5s, d5d ].min

    att, rem = [ :dex, d5d ] if type == 'Shoot'

    m = modifier(att)

    rem = 0 if rem < 0

    if type == 'Shoot'
      @shoot = (@shoot && @shoot[0] > rem) ? @shoot : [ rem, att ]
      rem, att = @shoot
    else
      @stab = (@stab && @stab[0] > rem) ? @stab : [ rem, att ]
      rem, att = @stab
    end

    "#{tb(rem + m)} (#{type} #{rem} #{att.to_s.upcase} #{tb(m)})"
  end

  def translate_attack_damage(type, dice)

#p [ :tad, type, dice, @shoot, @stab ]
    att = type == 'Shoot' ? @shoot.last : @stab.last

    " Hit: #{dice.split(/[-+]/).first}#{tb(modifier(att))} "
  end

  def tb(i); i < 0 ? i.to_s : "+#{i}"; end

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

    att5(att).match(/\A(\d+)/)[1].to_i
  end

  def mod5(att)

    att5(att).match(/\(([-+]\d+)\)/)[1].to_i
  end

  def att5(att)

    case att.to_s
    when /str/i then @abilities[0]
    when /dex/i then @abilities[1]
    when /con/i then @abilities[2]
    when /int/i then @abilities[3]
    when /wis/i then @abilities[4]
    when /cha/i then @abilities[5]
    else 0
    end
  end
end


#
# the Redcarpet Markdown renderer

class MdownToCreature < Redcarpet::Render::Base

  attr_reader :creature

  def initialize

    super
    @creature = Creature.new
  end

  def normal_text(text)

    FeetExpander.expand(text) { |s| s.gsub('_', '\_') }
  end

  def header(title, level)

    if level == 1
      @creature.name = title
    else
#p [ :header, title, level ]
      @creature.phase = title
      ''
    end
  end

  def double_emphasis(text)

    "**#{text}**"
  end

  def emphasis(text)

    if text.match?(/\A\*.+\*\z/)
      text
    elsif @creature.type == nil
      @creature.type = text
    elsif text.match(/\A\*\*[A-Z]/)
      text.gsub(/\.$/, '')
    else
#p [ :emphasis, text ]
      text
    end
  end

  def paragraph(text)

    if m = text.match(/^\*\*([^*]+)\*\* (.*)$/)
      @creature << [ m[1], m[2] ]
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
    @creature.abilities << content if content.match(/\d+/)
    ''
  end
end

def make_creature(pa)

  s = File.read(pa)
#puts "-" * 80; puts s.strip + "\n"; puts "-" * 80

  mtm = MdownToCreature.new

  Redcarpet::Markdown.new(mtm, tables: true).render(s)
  m = mtm.creature

  m
end


#
# the make functions

def make_creatures

  Dir[File.join(__dir__, '../sources/creatures/*.md')].each do |pa|

    fn = File.join('out/creatures', File.basename(pa))

    md =
      begin
        make_creature(pa).to_md
      rescue => err
        puts "   #{err.inspect}"
        nil
      end

    if md
      puts "...#{fn}"
      File.open(fn, 'wb') { |f| f.puts(md) }
    else
      puts "!!!#{fn}"
    end
  end
end

