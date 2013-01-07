class HashMatcher
  attr_reader :rules, :sets

  def initialize
    @rules = []
    @sets = {}
    @context = self
  end

  def include_folder folder
    Dir["#{folder}/*.rb"].each do |file|
      puts "incing #{file}"
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
      if regexes.any?{|r| string =~ r}
        matcher.analyze(string, data)
      end
    end
  end

  private

  def set sub_hash
    @context.sets.merge! stringified sub_hash
  end

  def match *args, &block
    matcher = HashMatcher.new
    old_context = @context
    @context.rules << [args, matcher]
    @context = matcher
    block.call
    @context = old_context
  end

  def stringified hash
    hash.keys.each do |key|
      val = hash.delete(key)
      hash[key.to_s] = val
    end
    hash
  end
end
