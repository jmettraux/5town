
module FeetExpander

  class << self

    def expand(s, &block)

      s
        .gsub(
          %r{
            (\d+\/)?
            (\d[.,]\d+|[.,]\d+|\d+)[- ]*
            (foot|feet|ft\.?)
          }xi) {
            s = expand_feet($1, $2, $3)
            block ? block.call(s) : s
          }
    end

    protected

    def expand_feet(r0, r1, unit)

      [ r0 ? do_expand_feet(r0) : nil, do_expand_feet(r1) ]
        .compact.join(' / ')
    end

    def rtos(range)

      case r = ("%.1f" % range)
      when /\.[1-9]/ then r.to_f.to_s
      when /\.0*/ then r.to_i.to_s
      else r
      end
    end

    def do_expand_feet(range)

      ft = range.to_i; return '0ft' if ft == 0
      m = ft * 0.3
      sq = ft * 0.2

      st = tost(ft)#; st = nil if st.match?(/\A\+\d\z/)

      [ "#{rtos(ft)}ft", "#{rtos(m)}m", "#{rtos(sq)}sq", st ]
        .compact
        .join('_')
    end

    #def len(s); s.each_char.inject(0) { |r, c| r + (c == 'F' ? 40 : 30) }; end

    def sort(s)

      cs = s.each_char
      fs = cs.count { |c| c == 'F' }
      ts = cs.count { |c| c == 't' }
#p [ cs, fs, ts ]
      rem = s.match(/(\+.+)?$/)[1]

      "#{'F' * fs}#{'t' * ts}#{rem}"
    end

    def tost(ft)

      return '' if ft == 0
      return "+#{rtos(ft / 5.0)}" if ft < 30

      t1 = ft / 30
      t1r = ft % 30

      "#{'t' * t1}#{tost(t1r)}"
        .gsub(/t\+4/, 'F+2').yield_self { |s| sort(s) }
        .gsub(/t\+2/, 'F').yield_self { |s| sort(s) }
        .gsub(/tttt/, 'FFF')
        .gsub(/F+/) { |s| s.length > 3 ? "#{s.length}F" : s }
    end
  end
end

