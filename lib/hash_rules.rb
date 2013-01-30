require 'hash_matcher'

class HashRules

  def initialize args
    @folder = args[:folder] || raise("No folder specified!")
    @field = args[:field] || raise("No field specified!")

    @hashmatcher = HashMatcher.new
    @hashmatcher.include_folder(@folder)
  end

  def process hash
    string = hash[@field].downcase
    string.gsub!('-', ' ')
    string.gsub!('/', ' ')
    string.gsub!(/\s+/, ' ')
    @hashmatcher.analyze(string, hash)
  end

  def to_s
    "== HASHRULES ==" << @hashmatcher.to_s
  end
end
