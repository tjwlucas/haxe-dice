package tests.cases.expressions;

import tests.mock.RandomGeneratorMock;
import dice.errors.InvalidExpression;
import utest.Assert;
import dice.expressions.SimpleRoll;
import utest.Test;

class SimpleRollTest extends Test {
    var generator : RandomGeneratorMock;
    var manager : dice.RollManager;
    function setup() {
        generator = new RandomGeneratorMock();
        manager = new dice.RollManager(generator);
    }

    function specBasicParse() {
        // Get empty, then parse expression
        var simpleRoll = manager.getSimpleRoll();
        var roll_expression = simpleRoll.parse('d6');
        roll_expression.sides == 6;
        roll_expression.number == 1;

        // Set expression in initial getSimpleRoll
        var roll_expression = manager.getSimpleRoll('d6');
        roll_expression.sides == 6;
        roll_expression.number == 1;

        var roll_expression = manager.getSimpleRoll('3d20');
        roll_expression.sides == 20;
        roll_expression.number == 3;

        var roll_expression = manager.getSimpleRoll('3D20');
        roll_expression.sides == 20;
        roll_expression.number == 3;

        Assert.raises(() -> {
            simpleRoll.parse('invalid');
        }, InvalidExpression);

        var roll_expression = simpleRoll.parse('d45q');
        roll_expression.sides == 45;
        roll_expression.number == 1;

        Assert.raises(() -> {
            simpleRoll.parse('asdd45q');
        }, InvalidExpression);

        Assert.raises(() -> {
            simpleRoll.parse('45q');
        }, InvalidExpression);
    }

    function specBuildDice() {
        generator.mock_results = [
            6 => [1,2,3],
            20 => [1,2,3,4],
            4 => [2]
        ];
        var testDiceBuild1 = manager.getSimpleRoll('3d6');
        testDiceBuild1.dice.length == 3;
        for (die in testDiceBuild1.dice) {
            die.sides == 6;
        }

        var testDiceBuild2 = manager.getSimpleRoll('4d20');
        testDiceBuild2.dice.length == 4;
        for (die in testDiceBuild2.dice) {
            die.sides == 20;
        }

        var testDiceBuild3 = manager.getSimpleRoll('d4');
        testDiceBuild3.dice.length == 1;
        for (die in testDiceBuild3.dice) {
            die.sides == 4;
        }
    }

    function specRollDice() {
        generator.mock_results[6] = [2,4,3,2,5,4];
        var testSimpleRoll = manager.getSimpleRoll('2d6');
        testSimpleRoll.dice[0].result == 2;
        testSimpleRoll.dice[1].result == 4;

        // Fetch again
        testSimpleRoll.dice[0].result == 2;
        testSimpleRoll.dice[1].result == 4;

        // Reroll
        testSimpleRoll.roll();
        testSimpleRoll.dice[0].result == 3;
        testSimpleRoll.dice[1].result == 2;
    }
}