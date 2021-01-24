
def list_weapons

  s = Set.new

  Dir['sources/creatures/*.md'].each do |pa|
    ls = File.readlines(pa)
    ai = ls.index("## Actions\n")
    ls[ai..-1].each do |l|
      m = l.match(/^\*\*\*([^*(]+)( \([^)]+\))?\*\*\* /)
      s << m[1].gsub('.', '') if m
    end
  end

  h = s.to_a.sort.inject({}) { |h, k| h[k] = '2/15'; h }

  puts YAML.dump(h)
end

