package tests.cases;

import tests.mock.NoMockResult;
import utest.Assert;
import utest.Test;
import tests.mock.RandomGeneratorMock;
import dice.errors.InvalidConstructor;

class BasicTestCase extends Test {
    var generator : RandomGeneratorMock;
    var manager : dice.RollManager;

    var sample_size = 10000;
    function setup() {
        generator = new RandomGeneratorMock();
        manager = new dice.RollManager(generator);
    }

    function specBasicDieRandomTests() {
        var realManager = new dice.RollManager();
        for(sides in [2,3,4,6,8,10,12,20,100]) {
            var die = realManager.getRawDie(sides);
            var rolls = [for (i in 1...sample_size) die.roll()];
            var count : Int = 0;
            var other_rolls = rolls;
            for(i in 0...sides) {
                var n = i+1;
                Assert.contains(n, rolls);
                other_rolls = other_rolls.filter(val -> val != n);
            }
            Assert.equals(0, other_rolls.length, "Unexpected rolls returned");
        }

        Assert.raises(() -> realManager.getRawDie(0), InvalidConstructor);
        Assert.raises(() -> realManager.getRawDie(-56), InvalidConstructor);
    }

    function specBasicDieMocking() {
        generator.mock_results[6] = [2,4,3];
        var d6 = manager.getRawDie(6);
        d6.result == 2;
        d6.roll() == 4;
        d6.result == 4;
        d6.roll() == 3;
        d6.result == 3;
        Assert.raises(() -> d6.roll(), NoMockResult);
        d6.result == 3;

        var d20 = manager.getRawDie(20);

        generator.mock_results[20] = [15, 1, 20];
        d20.result == 15;
        d20.roll() == 1;
        d20.roll() == 20;

        generator.shouldBeDoneAll();

        generator.mock_results = [
            6 => [1,2,3],
            20 => [3, 16, 20, 1]
        ];

        d6.roll() == 1;
        d6.roll() == 2;
        d20.roll() == 3;
        d20.roll() == 16;
        d20.roll() == 20;
        d6.roll() == 3;
        generator.shouldBeDone(6);
        Assert.raises(() -> d6.roll(), NoMockResult);
        d20.roll() == 1;
        generator.shouldBeDone(20);
        Assert.raises(() -> d20.roll(), NoMockResult);
    }

    function teardown() {
        generator.shouldBeDoneAll();
    }
}