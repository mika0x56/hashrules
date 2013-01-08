require 'test_helper'
require 'hash_rules'

class HashRulesTest < TestCase
  context 'hashrules' do

    setup do
      @it = HashRules.new({folder: 'test/examples', field: 'headline'})
    end

    should 'identify manufacturer' do
      data = {
        'headline' => "1986 Piper tjobahobo"
      }
      @it.process(data)
      assert_equal 'Piper', data['manufacturer']
    end

    should 'identify perfect match' do
      data = {'headline'=>"piper pa28-181 ii"}
      @it.process(data)
      assert_equal 'PA-28-181 Archer II', data['model']
    end

    should 'identify model' do
      data = {'headline'=>"2001 piper pa28-181 ii"}
      @it.process(data)
      assert_equal 'PA-28-181 Archer II', data['model']
    end

    should 'allow numbers or letter next to match' do
      data = {'headline'=>"apiperloon"}
      @it.process(data)
      assert_equal "Piper", data['manufacturer']
    end

    should 'match on string' do
      data = {'headline'=>"piper pa-28 181"}
      @it.process(data)
      assert_equal "PA-28-181", data['model']
    end

    should 'not allow numbers or letter next to STRING match' do
      data = {'headline'=>"piper apa-28 18100"}
      @it.process(data)
      assert_equal nil, data['model']
    end
  end
end
