class HashMatcher
  attr_reader :rules, :sets

  def initialize
    @rules = []
    @sets = {}
    @context = self
  end

  def include_folder folder
    Dir["#{folder}/*.rb"].each do |file|
      @current_folder = folder
      contents = File.read(file)
      eval(contents, binding)
    end
  end

  def include_subfolder folder
    include_folder "#{@current_folder}/#{folder}"
  end

  def to_s i=0
    result = ""
    sets.each do |k,v|
      result << "#{" "*i}#{k} = #{v}\n"
    end
    rules.each do |regexes, matcher|
      result << "\n#{" "*i}If match #{regexes.to_s}\n"
      result << matcher.to_s(i+1)
      result << "#{" "*i}End\n"
    end
    result
  end

  def analyze string, opts={}
    matches = []
    opts[:limit] ||= 1
    skip_levels = opts[:skip_levels] || 0

    rules.each do |regexes, matcher|
      offsets = []
      if skip_levels > 0 || regexes.find{|r| offsets=test(string,r)}
        opts[:skip_levels] = skip_levels-1
        sub_matches = matcher.analyze(string, opts)
        
        sub_matches.map do |m| 
          m['data'] = sets.merge(m['data'])
          m['coverage'] += offsets if offsets
        end

        matches += sub_matches

        if skip_levels <= 0
          opts[:limit] -= 1
        end

        if (opts[:limit]) == 0
          break
        end
      end
    end
    if matches.empty? && skip_levels < 0
      matches << { 'data' => sets.dup, 'coverage' => [], match_id: self.object_id}
    end

    matches
  end

  private

  def test string, matcher
    if matcher.is_a?(NoClass)
      m = test(string,matcher.regex)
      [[-1,-1]] if !m
    elsif matcher.is_a?(AndClass)
      r = matcher.regexes.map{|r| a=test(string,r); a[0] if a}
      if r.all?{|r| r}
        r.find_all{|r| r[0] != -1}
      end
    else
      m = matcher.match(string)
      [m.offset(0)] if m
    end
  end

  def set sub_hash
    @context.sets.merge! stringified sub_hash
  end

  def match *args, &block
    regexes = args.map{|r| to_regex(r)}
    matcher = HashMatcher.new
    old_context = @context
    old_folder = @current_folder
    @context.rules << [regexes, matcher]
    @context = matcher
    block.call
    @context = old_context
    @current_folder = old_folder
  end

  def w(regex) # make it match whole words
    /(^| )#{regex.source}($| )/
  end

  def no(regex)
    NoClass.new(to_regex(regex))
  end

  def both(*regexes)
    AndClass.new(to_regex(regexes))
  end

  def to_regex(matcher)
    if matcher.kind_of?(String)
      /(^| )#{Regexp.escape(matcher)}($| )/
    elsif matcher.kind_of?(Array) 
      matcher.map{|r| to_regex(r)}
    else
      matcher
    end
  end

  def stringified hash
    hash.keys.each do |key|
      val = hash.delete(key)
      hash[key.to_s] = val
    end
    hash
  end

  class NoClass
    attr_reader :regex

    def initialize regex
      @regex = regex
    end

    def to_s
      "!(#{@regex})"
    end
  end

  class AndClass
    attr_reader :regexes

    def initialize regexes
      @regexes = regexes
    end

    def to_s
      @regexes.map{|r| r.inspect}.join(' AND ')
    end
  end
end
