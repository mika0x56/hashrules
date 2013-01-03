
class HashRules

  def initialize args
    @folder = args[:folder] || raise("No folder specified!")
    @field = args[:field] || raise("No field specified!")
  end

end
