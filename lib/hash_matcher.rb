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
      end
    end
  end

  private

  def test string, regex
    match = string.match(regex)
    if match
      pre_cond = (match.pre_match == "" || match.pre_match =~ /[^\d\w]$/)
      post_cond = (match.post_match == "" || match.post_match =~ /^[^\w\d]/)

      pre_cond && post_cond
    end
  end

  def set sub_hash
    @context.sets.merge! stringified sub_hash
  end

  def match *args, &block
    matcher = HashMatcher.new
    old_context = @context
    old_folder = @current_folder
    @context.rules << [args, matcher]
    @context = matcher
    block.call
    @context = old_context
    @current_folder = old_folder
  end

  def stringified hash
    hash.keys.each do |key|
      val = hash.delete(key)
      hash[key.to_s] = val
    end
    hash
  end
end
