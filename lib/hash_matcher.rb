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

  def analyze string, data={}
    data.merge! sets

    rules.each do |regexes, matcher|
      if regexes.any?{|r| test(string,r)}
        matcher.analyze(string, data)
        break
      end
    end
  end

  private

  def test string, matcher
    if matcher.is_a?(NoClass)
      !(string =~ matcher.regex)
    elsif matcher.is_a?(AndClass)
      matcher.regexes.all?{|r| string =~ r}
    else
      string =~ matcher
    end
  end

  def set sub_hash
    @context.sets.merge! stringified sub_hash
  end

  def match *args, &block
    regexes = args.map do |arg|
      if arg.kind_of?(String)
        /(^| )#{Regexp.escape(arg)}($| )/
      else
        arg
      end
    end
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
    NoClass.new(regex)
  end

  def both(*regexes)
    AndClass.new(regexes)
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
  end

  class AndClass
    attr_reader :regexes

    def initialize regexes
      @regexes = regexes
    end
  end
end
