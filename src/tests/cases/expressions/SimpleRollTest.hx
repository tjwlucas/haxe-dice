package tests.cases.expressions;

import dice.errors.InvalidModifier;
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
        @:privateAccess roll_expression.expression = 'd6';

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
        @:privateAccess roll_expression.expression = 'd45q';

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
        testSimpleRoll.total == 6;

        // Fetch again
        testSimpleRoll.dice[0].result == 2;
        testSimpleRoll.dice[1].result == 4;
        testSimpleRoll.total == 6;

        // Reroll
        testSimpleRoll.roll();
        testSimpleRoll.dice[0].result == 3;
        testSimpleRoll.dice[1].result == 2;
        testSimpleRoll.total == 5;
    }

    function specGetModifier() {
        var roll_expression = manager.getSimpleRoll('d45q1');
        @:privateAccess roll_expression.getModifier('q') == 1;
        Assert.isNull(@:privateAccess roll_expression.getModifier('!'));
        Assert.isNull(@:privateAccess roll_expression.getModifier('k'));

        var roll_expression = manager.getSimpleRoll('d45!q3f2k');
        @:privateAccess roll_expression.getModifier('q') == 3;
        @:privateAccess roll_expression.getModifier('f') == 2;
        @:privateAccess roll_expression.getModifier('k') == 1;
        @:privateAccess roll_expression.getModifier('!') == 45;

        var roll_expression = manager.getSimpleRoll('d45q3f2q2');
        Assert.raises(() -> {
            @:privateAccess roll_expression.getModifier('q');
        }, InvalidExpression);


        var roll_expression = manager.getSimpleRoll('3d20k!l');
        @:privateAccess roll_expression.getModifier('k') == 1;
        @:privateAccess roll_expression.getModifier('l') == 1;

        @:privateAccess roll_expression.getModifier('!') == 20;
        Assert.equals(
            @:privateAccess roll_expression.getModifier('f'),
            null
        );

        Assert.raises(() -> {
            @:privateAccess roll_expression.getModifier('long');
        }, InvalidModifier);

        Assert.raises(() -> {
            @:privateAccess roll_expression.getModifier('');
        }, InvalidModifier);
    }

    function specExplodingExpression() {        
        generator.mock_results[6] = [2];
        var roll1 = manager.getSimpleRoll('d6!');
        roll1.dice.length == 1;
        roll1.dice[0].result == 2;
        roll1.total == 2;
      
        generator.mock_results[6] = [6,3,2];
        var roll2 = manager.getSimpleRoll('d6!');
        roll2.dice.length == 1;
        roll2.dice[0].result == 9;
        roll2.total == 9;

        generator.mock_results[6] = [6,4,3,6,1];
        var roll3 = manager.getSimpleRoll('3d6!');
        roll3.total == 20;
        roll3.dice[0].result == 10;
        roll3.dice[1].result == 3;
        roll3.dice[2].result == 7;

        generator.mock_results[4] = [3,2,4,3,1];
        var roll4 = manager.getSimpleRoll('2d4!3');        
        roll4.dice[0].result == 5;
        roll4.dice[1].result == 8;
        roll4.total == 13;
    }
}