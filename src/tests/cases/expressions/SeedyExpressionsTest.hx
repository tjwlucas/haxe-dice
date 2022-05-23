package tests.cases.expressions;

import dice.RandomGenerator;
import utest.Assert;
import utest.Test;

class SeedyExpressionsTest extends Test {

    function specSeedyResults() {
        var generator = new RandomGenerator(Seedy("specSeedyResults"));
        var manager = new dice.RollManager(generator);
        var expression = manager.getComplexExpression('(3d6! / 2) + d4');
        expression.result == 6;
        expression.roll() == 13.5;
        expression.roll() == 7;
        expression.roll() == 12;
        expression.roll() == 6.5;
        expression.roll() == 8.5;
    }

    /**
        Check that the shuffle function shuffles predictably, based on the given RNG
    **/
    function specSeedyShuffle() {
        var generator = new RandomGenerator(Seedy("specSeedyShuffle"));
        var manager = new dice.RollManager(generator);
        var expression = manager.getSimpleRoll('5d6');
        expression.roll();

        Assert.same(
            [1, 3, 5, 3, 3],
            [for (r in expression.rolledDice) r.result]
        );
        expression.shuffle();

        Assert.same(
            [3, 5, 3, 3, 1],
            [for (r in expression.rolledDice) r.result]
        );
    }
}