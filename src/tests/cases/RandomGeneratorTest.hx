package tests.cases;

import dice.RandomGenerator;
import utest.Test;
import tests.mock.RandomGeneratorMock;
import utest.Assert;
using Math;

class RandomGeneratorTest extends Test {
    var generator : RandomGenerator;
    var sampleSize : Int = 10000;
    function setup() {
        generator = new RandomGenerator();
    }

    function specRandom() {
        var tooLarge : Array<Float> = [];
        var tooSmall : Array<Float> = [];
        for (i in 0...sampleSize) {
            var rand = @:privateAccess generator.random();
            if (rand >= 1) {
                tooLarge.push(rand);
            }
            if (rand < 0) {
                tooSmall.push(rand);
            }
        }
        Assert.same([], tooLarge);
        Assert.same([], tooSmall);
    }

    function specRandomInt() {
        var tooLarge : Array<Int> = [];
        var tooSmall : Array<Int> = [];
        for (sides in [1, 2, 3, 4, 6, 8, 12, 20, 100]) {
            for (i in 0...sampleSize) {
                var rand = generator.rollPositiveInt(sides);
                if (rand > sides) {
                    tooLarge.push(rand);
                }
                if (rand < 1) {
                    tooSmall.push(rand);
                }
            }
            Assert.same([], tooLarge);
            Assert.same([], tooSmall);
        }
    }

    /**
        Deterministically check output of basic randomInt function, that it covers all expected results, only expected results, and fairly distributed.
        (Assumes the even distribution of the raw random function of a float between 0 and 1)
    **/
    function specDeterministicDistribution() {
        var mockGenerator = new RandomGeneratorMock();
        mockGenerator.useRaw = true;

        for (sides in [2, 3, 4, 6, 8, 10, 12, 20, 100]) {
            // The random number generator being used return 0 <= n < 1
            mockGenerator.mockRawResults = [for (i in 0...sampleSize) i / sampleSize];
            mockGenerator.mockRawResults.length == sampleSize;
            var rolls = [for (i in 0...sampleSize) mockGenerator.rollPositiveInt(sides)];
            var expectedN = sampleSize / sides;

            var counts : Map<Int, Int> = [];

            rolls.map(value -> counts.exists(value) ? counts[value]++ : counts[value] = 1 );

            for (i in 0...sides) {
                var n = i + 1;
                Assert.isTrue(counts.exists(n), '$n not rolled at all on d$sides');
                if (counts.exists(n)) {
                    Assert.isTrue(counts[n] <= expectedN + 1, '$n is being rolled too much on d$sides (${(counts[n]*100/expectedN).round()}% of expected)');
                    Assert.isTrue(counts[n] >= expectedN - 1, '$n is not being rolled enough on d$sides (${(counts[n]*100/expectedN).round()}% of expected)');
                }
            }
            for (key => value in counts) {
                if (key < 1 || key > sides) {
                    Assert.fail('Unexpected roll returned on d$sides: $key (${value * 100 / sampleSize}%)');
                }
            }
            mockGenerator.shouldBeDoneRaw();
        }
        mockGenerator.useRaw = false;
    }
}
