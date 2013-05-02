# encoding: utf-8

require 'test_helper'
require 'hash_rules'

class HashRulesTest < TestCase
  context 'hashrules, normal operation' do

    setup do
      @it = HashRules.new(folder: 'test/examples')
    end

    should 'return empty array when no match' do
      assert_equal [], @it.process('curry')
    end

    should 'identify manufacturer' do
      data = @it.process("1986 piper tjobahobo").first['data']
      assert_equal 'Piper', data['manufacturer']
    end

    should 'identify perfect match' do
      data = @it.process("piper pa28 181 ii").first['data']
      assert_equal 'PA-28-181 Archer II', data['model']
    end

    should 'identify model' do
      data = @it.process("2001 piper pa28 181 ii").first['data']
      assert_equal 'PA-28-181 Archer II', data['model']
    end

    should 'allow numbers or letter next to match' do
      data = @it.process("apiperloon").first['data']
      assert_equal "Piper", data['manufacturer']
    end

    should 'match on string' do
      data = @it.process("piper pa 28 181").first['data']
      assert_equal "PA-28-181", data['model']
    end

    should 'discard double whitespace' do
      data = @it.process("piper \t\r \npa 28\n 181").first['data']
      assert_equal "PA-28-181", data['model']
    end

    should 'use "word" to make regexes match whole words' do
      data = @it.process("piper apa-280").first['data']
      assert_equal nil, data['family']
    end

    should 'present us with matched slices and percentage covered' do
      data = @it.process("i'd like a piper in the pa28 family")
      first = data.first

      assert_equal 'Piper', first['data']['manufacturer']
      assert_equal [[24, 27], [11, 15]], first['coverage']
      assert_equal 25, first['percent_coverage']
    end

    context 'both and no' do
      should 'make operation trees' do
        result = @it.process('person')
        assert_equal 'Per', result.first['data']['manufacturer']
      end

      should 'use both with strings and regexes' do
        data = @it.process('string rregexx').first['data']
        assert_equal 'success', data['manufacturer']
      end
    end


    should 'not allow numbers or letter next to STRING match' do
      data = @it.process("piper apa-28 18100").first['data']
      assert_equal nil, data['model']
    end

    should 'not allow several matches in the same context' do
      # note: the rules are written in regex /ii/ which means it will also match /iii/
      data = @it.process('piper pa28 181 archer iii', limit: 1).first['data']
      assert_equal 'PA-28-181 Archer II', data['model']
    end

    context "case insensitive" do
      should 'match cyrillic letters' do
        data = @it.process("ми 8т").first['data']
        assert_equal "Ми-8Т", data['manufacturer']
      end
    end
  end

  context 'multimatch' do

    setup do
      @it = HashRules.new(folder: 'test/examples')
    end

    should 'match several if indicated' do
      r = @it.process('this should return two match', limit: -1)
      assert_equal 2, r.count
      first, second = r

      assert_equal 'first', first['data']['match']
      assert_equal 'second', second['data']['match']
    end
  end

  context 'hashrules, submatch' do

    setup do
      @it = HashRules.new(folder: 'test/examples')
    end

    should 'match with adequate information, just as without submatch' do
      r = @it.process('oregon ohio united states').first['data']
      assert_equal 'United States', r['country']
      assert_equal 'Ohio', r['region']
      assert_equal 'Oregon', r['city']

      r = @it.process('canada oregon').first['data']
      assert_equal 'Canada', r['country']
      assert_equal 'Oregon', r['region']
      assert_equal nil, r['city']
    end

    should 'prefer to match on 2:nd level over 3:rd level' do
      r = @it.process('oregon', max_submatch_level: 1, limit: 1).first['data']

      # united states have a city called 'oregon', but which is on 3rd level,
      # Oregon in canada is a state, and on the 2nd level
      assert_equal 'Canada', r['country']
    end

    should 'strive for 100% matach if possible' do
      r = @it.process('oregon ohio', max_submatch_level: 5, limit: -1)

      assert_equal 3, r.count

      # Without intelligence, Oregon (canada) would be chosen because it's a state on the 2nd level, and Oregon in US is a city on 3rd level. However, we reason that if a 3rd level match can explain more about a string then it is reasonably more likely to be accurate.
      
      assert_equal 'Ohio', r[0]['data']['region']
    end

    should 'backtrack coverage when found submatch' do
      r = @it.process('pearson ohio', max_submatch_level: 6, limit: -1)

      assert_equal [[0,6],[8,11]], r[0]['coverage']
    end

    should 'include matchlevel' do
      r = @it.process('pearson ohio', max_submatch_level: 6, limit: -1)
      assert_equal 2, r[0]['matchlevel']

      r = @it.process('oregon', max_submatch_level: 6, limit: -1)
      assert_equal 'Canada', r[0]['data']['country']
      assert_equal 2, r[0]['matchlevel']
      assert_equal 'United States', r[1]['data']['country']
      assert_equal 3, r[1]['matchlevel']
    end
  end
end
