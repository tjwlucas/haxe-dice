package tests.cases;

import dice.RandomGenerator;
import utest.Test;
import tests.mock.RandomGeneratorMock;
import utest.Assert;
using Math;

class RandomGeneratorTest extends Test {
    var generator : RandomGenerator;
    var sample_size = 10000;
    function setup() {
        generator = new RandomGenerator();
    }
    
    function specRandom() {
        var too_large : Array<Float> = [];
        var too_small : Array<Float> = [];
        for(i in 0...sample_size) {
            var rand = @:privateAccess generator.random();
            if(rand >= 1) {
                too_large.push(rand);
            }
            if(rand < 0) {
                too_small.push(rand);
            }
        }
        Assert.same([], too_large);
        Assert.same([], too_small);
    }
    
    function specRandomInt() {
        var too_large : Array<Int> = [];
        var too_small : Array<Int> = [];
        for(sides in [1,2,3,4,6,8,12,20,100]) {
            for(i in 0...sample_size) {
                var rand = generator.rollPositiveInt(sides);
                if(rand > sides) {
                    too_large.push(rand);
                }
                if(rand < 1) {
                    too_small.push(rand);
                }
            }
            Assert.same([], too_large);
            Assert.same([], too_small);
        }
    }

    /**
        Deterministically check output of basic randomInt function, that it covers all expected results, only expected results, and fairly distributed.
        (Assumes the even distribution of the raw random function of a float between 0 and 1)
    **/
    function specDeterministicDistribution() {
        var mock_generator = new RandomGeneratorMock();
        mock_generator.use_raw = true;

        for(sides in [2,3,4,6,8,10,12,20,100]) {
            // The random number generator being used return 0 <= n < 1
            mock_generator.mock_raw_results = [for (i in 0...sample_size) i / sample_size];
            mock_generator.mock_raw_results.length == sample_size;
            var rolls = [for (i in 0...sample_size) mock_generator.rollPositiveInt(sides)];
            var count : Int = 0;
            var other_rolls = rolls;
            var expected_n = sample_size / sides;

            var counts : Map<Int, Int> = [];

            rolls.map(value -> counts.exists(value) ? counts[value]++ : counts[value] = 1 );

            for(i in 0...sides) {
                var n = i+1;
                Assert.isTrue(counts.exists(n), '$n not rolled at all on d$sides');
                if(counts.exists(n)) {
                    Assert.isTrue(counts[n] <= expected_n + 1, '$n is being rolled too much on d$sides (${(count*100/expected_n).round()}% of expected)');
                    Assert.isTrue(counts[n] >= expected_n - 1, '$n is not being rolled enough on d$sides (${(count*100/expected_n).round()}% of expected)');
                }
            }
            for(key => value in counts) {
                if(![for (i in 0...sides) i + 1].contains(key)) {
                    Assert.fail('Unexpected roll returned on d$sides: $key (${value * 100 / sample_size}%)');
                }
            }
            mock_generator.shouldBeDoneRaw();
        }
        mock_generator.use_raw = false;
    }
}
