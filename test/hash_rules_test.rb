require 'test_helper'
require 'hash_rules'

class HashRulesTest < TestCase
  context 'hashrules' do

    setup do
      @it = HashRules.new({folder: 'test/examples', field: 'title'})
    end

    should 'identify manufacturer' do
      data = {
        'headline' => "1986 Piper tjobahobo"
      }
      @it.process(data)
      assert_equal 'Piper', data['manufacturer']
    end
  end
end
