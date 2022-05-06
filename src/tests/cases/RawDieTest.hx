package tests.cases;

import tests.mock.NoMockResult;
import utest.Assert;
import utest.Test;
import tests.mock.RandomGeneratorMock;
import dice.errors.InvalidConstructor;

using Math;

class RawDieTest extends Test {
    var generator : RandomGeneratorMock;
    var manager : dice.RollManager;

    function setup() {
        generator = new RandomGeneratorMock();
        manager = new dice.RollManager(generator);
    }

    function specValidConstruction() {
        var die = manager.getRawDie(6);
        die.sides == 6;

        Assert.raises(() -> var die = manager.getRawDie(0), InvalidConstructor);
        Assert.raises(() -> var die = manager.getRawDie(-4), InvalidConstructor);
        //Test against invalid values provided dynamically (at runtime)
        Assert.raises(() -> var die = manager.getRawDie((2.3:Any)), InvalidConstructor);
        Assert.raises(() -> var die = manager.getRawDie((-0.3:Any)), InvalidConstructor);

        var die = manager.getRawDie( (3.0:Any) );
        die.sides == 3;
    }

    function specBasicDieMocking() {
        generator.mockResults[6] = [2, 4, 3];
        var d6 = manager.getRawDie(6);
        d6.result == 2;
        d6.roll() == 4;
        d6.result == 4;
        d6.roll() == 3;
        d6.result == 3;
        Assert.raises(() -> d6.roll(), NoMockResult);
        d6.result == 3;

        var d20 = manager.getRawDie(20);

        generator.mockResults[20] = [15, 1, 20];
        d20.result == 15;
        d20.roll() == 1;
        d20.roll() == 20;

        generator.shouldBeDoneAll();

        generator.mockResults = [
            6 => [1, 2, 3],
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