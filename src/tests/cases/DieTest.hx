package tests.cases;

import dice.errors.InvalidConstructor;
import utest.Assert;
import tests.mock.RandomGeneratorMock;
import utest.Test;

class DieTest extends Test {
    var generator : RandomGeneratorMock;
    var manager : dice.RollManager;

    var sample_size = 10000;
    function setup() {
        generator = new RandomGeneratorMock();
        manager = new dice.RollManager(generator);
    }

    function specBasicDie() {
        generator.mock_results[6] = [2,6,2];
        var die1 = manager.getDie(6);
        die1.result == 2;
        die1.roll().result == 6;
        die1.roll().result == 2;
    }

    function specExplodingDie() {
        generator.mock_results[6] = [2,4,6,3];
        // With exploding 6
        var die1 = manager.getDie(6, 6);
        die1.result == 2;
        die1.roll().result == 4;
        die1.roll().result == 9;

        generator.mock_results[6] = [4,6,5,3];
        // With exploding on 4+
        var die2 = manager.getDie(6, 4);
        die2.result == 18;
    }

    function specGetDie() {
        var die = manager.getDie(20, 20);
        die.sides == 20;
        @:privateAccess die.explode == 20;

        Assert.raises(() -> manager.getDie(6,1), InvalidConstructor);

        Assert.raises(() -> manager.getDie(6,7), InvalidConstructor);

        Assert.raises(() -> manager.getDie(6,0), InvalidConstructor);

        Assert.raises(() -> manager.getDie(6,-3), InvalidConstructor);
    }
}