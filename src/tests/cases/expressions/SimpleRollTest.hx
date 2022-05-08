package tests.cases.expressions;

import tests.mock.RandomGeneratorMock;
import dice.errors.InvalidExpression;
import utest.Assert;
import utest.Test;

using dice.expressions.SimpleRoll;

class SimpleRollTest extends Test {
    var generator : RandomGeneratorMock;
    var manager : dice.RollManager;
    function setup() {
        generator = new RandomGeneratorMock();
        manager = new dice.RollManager(generator);
    }

    function specBasicParseMacro() {
        // Get empty, then parse expression
        var rollExpression = manager.getSimpleRoll('d6');
        rollExpression.sides == 6;
        rollExpression.number == 1;
        @:privateAccess rollExpression.expression == 'd6';

        var rollExpression = manager.getSimpleRoll('3d20');
        rollExpression.sides == 20;
        rollExpression.number == 3;

        var rollExpression = manager.getSimpleRoll('3D20');
        rollExpression.sides == 20;
        rollExpression.number == 3;

        Assert.raises(() -> manager.getSimpleRoll('invalid'), InvalidExpression);

        Assert.raises(() -> manager.getSimpleRoll('d45q'), InvalidExpression);

        Assert.raises(() -> manager.getSimpleRoll('asdd45q'), InvalidExpression);

        Assert.raises(() -> manager.getSimpleRoll('45q'), InvalidExpression);
    }

    function specBasicParseRuntime() {
        // Get empty, then parse expression
        var expr = 'd6';
        var rollExpression = manager.getSimpleRoll(expr);
        rollExpression.sides == 6;
        rollExpression.number == 1;
        @:privateAccess rollExpression.expression == 'd6';

        var expr = '3d20';
        var rollExpression = manager.getSimpleRoll(expr);
        rollExpression.sides == 20;
        rollExpression.number == 3;

        var expr = '3D20';
        var rollExpression = manager.getSimpleRoll(expr);
        rollExpression.sides == 20;
        rollExpression.number == 3;

        var expr = 'invalid';
        Assert.raises(() -> manager.getSimpleRoll(expr), InvalidExpression);

        var expr = 'd45q';
        Assert.raises(() -> manager.getSimpleRoll(expr), InvalidExpression);

        var expr = 'asdd45q';
        Assert.raises(() -> manager.getSimpleRoll(expr), InvalidExpression);

        var expr = '45q';
        Assert.raises(() -> manager.getSimpleRoll(expr), InvalidExpression);
    }

    function specBuildDice() {
        generator.mockResults = [
            6 => [1, 2, 3],
            20 => [1, 2, 3, 4],
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
        generator.mockResults[6] = [2, 4, 3, 2, 5, 4];
        var testSimpleRoll = manager.getSimpleRoll('2d6');
        Assert.same(
            [2, 4],
            [for (die in testSimpleRoll.dice) die.result]
        );
        testSimpleRoll.total == 6;

        // Fetch again
        Assert.same(
            [2, 4],
            [for (die in testSimpleRoll.dice) die.result]
        );
        testSimpleRoll.total == 6;

        // Reroll
        testSimpleRoll.roll();
        Assert.same(
            [3, 2],
            [for (die in testSimpleRoll.dice) die.result]
        );
        testSimpleRoll.total == 5;
    }

    function specgetModifierValue() {
        var rollExpression = 'd45';
        Assert.isNull(@:privateAccess rollExpression.getModifierValue(EXPLODE));
        Assert.isNull(@:privateAccess rollExpression.getModifierValue(KEEP));

        var rollExpression = 'd45!k';
        @:privateAccess rollExpression.getModifier(KEEP) == 'k';
        @:privateAccess rollExpression.getModifierValue(KEEP) == 1;
        @:privateAccess rollExpression.getModifierValue(EXPLODE) == 45;

        var rollExpression = '3d20k!';
        @:privateAccess rollExpression.getModifier(KEEP) == 'k';
        @:privateAccess rollExpression.getModifierValue(KEEP) == 1;

        @:privateAccess rollExpression.getModifierValue(EXPLODE) == 20;
    }

    function specExplodingExpressionMacro() {
        generator.mockResults[6] = [2];
        var roll1 = manager.getSimpleRoll('d6!');
        Assert.same(
            [2],
            [for (die in roll1.dice) die.result]
        );
        roll1.total == 2;

        generator.mockResults[6] = [6, 3, 2];
        var roll2 = manager.getSimpleRoll('d6!');
        Assert.same(
            [9],
            [for (die in roll2.dice) die.result]
        );
        roll2.total == 9;

        generator.mockResults[6] = [6, 4, 3, 6, 1];
        var roll3 = manager.getSimpleRoll('3d6!');
        roll3.total == 20;
        Assert.same(
            [10, 3, 7],
            [for (die in roll3.dice) die.result]
        );

        generator.mockResults[4] = [3, 2, 4, 3, 1];
        var roll4 = manager.getSimpleRoll('2d4!3');
        Assert.same(
            [5, 8],
            [for (die in roll4.dice) die.result]
        );
        roll4.total == 13;

        generator.mockResults[6] = [6, 4, 3, 6, 1];
        var roll3 = manager.getSimpleRoll('3d6!!');
        roll3.total == 18;
        Assert.same(
            [9, 3, 6],
            [for (die in roll3.dice) die.result]
        );

        generator.mockResults[4] = [3, 2, 4, 3, 1];
        var roll4 = manager.getSimpleRoll('2d4!!3');
        Assert.same(
            [4, 6],
            [for (die in roll4.dice) die.result]
        );
        roll4.total == 10;

        Assert.raises(() -> manager.getSimpleRoll('3d6!!!'), InvalidExpression);
    }

    function specExplodingExpressionRunTime() {
        generator.mockResults[6] = [2];
        var expr = "d6!";
        var roll1 = manager.getSimpleRoll(expr);
        Assert.same(
            [2],
            [for (die in roll1.dice) die.result]
        );
        roll1.total == 2;

        generator.mockResults[6] = [6, 3, 2];
        var roll2 = manager.getSimpleRoll(expr);
        Assert.same(
            [9],
            [for (die in roll2.dice) die.result]
        );
        roll2.total == 9;

        generator.mockResults[6] = [6, 4, 3, 6, 1];
        var expr = "3d6!";
        var roll3 = manager.getSimpleRoll(expr);
        roll3.total == 20;
        Assert.same(
            [10, 3, 7],
            [for (die in roll3.dice) die.result]
        );

        generator.mockResults[4] = [3, 2, 4, 3, 1];
        var expr = '2d4!3';
        var roll4 = manager.getSimpleRoll(expr);
        Assert.same(
            [5, 8],
            [for (die in roll4.dice) die.result]
        );
        roll4.total == 13;

        generator.mockResults[6] = [6, 4, 3, 6, 1];
        var expr = '3d6!!';
        var roll3 = manager.getSimpleRoll(expr);
        roll3.total == 18;
        Assert.same(
            [9, 3, 6],
            [for (die in roll3.dice) die.result]
        );

        generator.mockResults[4] = [3, 2, 4, 3, 1];
        var expr = "2d4!!3";
        var roll4 = manager.getSimpleRoll(expr);
        Assert.same(
            [4, 6],
            [for (die in roll4.dice) die.result]
        );
        roll4.total == 10;

        var expr = "3d6!!!";
        Assert.raises(() -> manager.getSimpleRoll(expr), InvalidExpression);
    }

    function specKeepHighest() {
        generator.mockResults[6] = [2, 6, 4, 3, 5];
        var roll1 = manager.getSimpleRoll('5d6');
        @:privateAccess roll1.keepHighest(3);
        roll1.total == 15;  // 6 + 5 + 4
        Assert.same(
            [6, 4, 5],
            [for (die in roll1.dice) die.result]
        );

        generator.mockResults[6] = [2, 6, 4, 3, 5, 2];
        var roll1 = manager.getSimpleRoll('5d6!');
        @:privateAccess roll1.keepHighest(3);
        roll1.total == 18;  // 10 (i.e. 6 + 4) + 5 + 3
        Assert.same(
            [10, 3, 5],
            [for (die in roll1.dice) die.result]
        );
    }

    function specKeepHighestExpression() {
        generator.mockResults[6] = [2, 6, 4, 3, 5];
        var roll = manager.getSimpleRoll('5d6k3');
        roll.total == 15;  // 6 + 5 + 4
        Assert.same(
            [6, 4, 5],
            [for (die in roll.dice) die.result]
        );

        generator.mockResults[6] = [2, 6, 4, 3, 5];
        var roll = manager.getSimpleRoll('5d6h3');
        roll.total == 15;  // 6 + 5 + 4
        Assert.same(
            [6, 4, 5],
            [for (die in roll.dice) die.result]
        );

        Assert.raises(() -> manager.getSimpleRoll('5d6h3k'), InvalidExpression);

        Assert.raises(() -> manager.getSimpleRoll('5d6h0'), InvalidExpression);

        Assert.raises(() -> manager.getSimpleRoll('3d6k4'), InvalidExpression);

        generator.mockResults[6] = [2, 6, 4, 3, 5];
        var roll = manager.getSimpleRoll('5d6k');
        roll.total == 6;
        Assert.same(
            [6],
            [for (die in roll.dice) die.result]
        );

        generator.mockResults[6] = [2, 6, 4, 3, 5, 3];
        var roll = manager.getSimpleRoll('5d6!k');
        roll.total == 10;
        Assert.same(
            [10],
            [for (die in roll.dice) die.result]
        );
    }

    function specKeepLowest() {
        generator.mockResults[6] = [2, 6, 4, 3, 5];
        var roll = manager.getSimpleRoll('5d6');
        @:privateAccess roll.keepLowest(3);
        roll.total == 9;
        Assert.same(
            [2, 4, 3],
            [for (die in roll.dice) die.result]
        );

        generator.mockResults[6] = [2, 6, 4, 3, 5, 2];
        var roll = manager.getSimpleRoll('5d6!');
        @:privateAccess roll.keepLowest(3);
        roll.total == 7;  // 2 + 2 + 3
        Assert.same(
            [2, 3, 2],
            [for (die in roll.dice) die.result]
        );

        generator.mockResults[6] = [6, 3, 6, 4, 6, 6, 1, 2, 5];
        var roll = manager.getSimpleRoll('5d6!');
        @:privateAccess roll.keepLowest(3);
        roll.total == 16;  // 2 + 5 + 9
        Assert.same(
            [9, 2, 5],
            [for (die in roll.dice) die.result]
        );
    }

    function specKeepLowestExpression() {
        generator.mockResults[6] = [2, 6, 4, 3, 5];
        var roll = manager.getSimpleRoll('5d6l3');
        roll.total == 9;
        Assert.same(
            [2, 4, 3],
            [for (die in roll.dice) die.result]
        );

        Assert.raises(() -> manager.getSimpleRoll('5d6h3l'), InvalidExpression);

        Assert.raises(() -> manager.getSimpleRoll('5d6l0'), InvalidExpression);

        Assert.raises(() -> manager.getSimpleRoll('3d6l4'), InvalidExpression);

        generator.mockResults[6] = [2, 6, 4, 3, 5];
        var roll = manager.getSimpleRoll('5d6l');
        roll.total == 2;
        Assert.same(
            [2],
            [for (die in roll.dice) die.result]
        );

        generator.mockResults[6] = [2, 6, 4, 3, 5, 3];
        var roll = manager.getSimpleRoll('5d6!l');
        roll.total == 2;
        Assert.same(
            [2],
            [for (die in roll.dice) die.result]
        );
    }

    function specShuffle() {
        generator.mockResults[6] = [2, 6, 4];
        var roll = manager.getSimpleRoll('3d6');
        roll.roll();
        Assert.same(
            [2, 6, 4],
            [for (die in roll.dice) die.result]
        );

        generator.mockResults = [
            3 => [2],
            2 => [1],
            1 => [1]
        ];
        roll.shuffle();
        Assert.same(
            [6, 2, 4],
            [for (die in roll.dice) die.result]
        );

        var roll = manager.getSimpleRoll('6d20');
        generator.mockResults = [
            20 => [12, 2, 3, 17, 1, 20],
            6 => [5],
            5 => [3],
            4 => [2],
            3 => [3],
            2 => [1],
            1 => [1]
        ];
        Assert.same(
            [12, 2, 3, 17, 1, 20],
            [for (die in roll.dice) die.result]
        );
        roll.shuffle();
        Assert.same(
            [1, 3, 2, 20, 12, 17],
            [for (die in roll.dice) die.result]
        );
    }

    function specShuffleWithoutResults() {
        generator.mockResults = [];
        var roll = manager.getSimpleRoll('3d6');
        roll.shuffle();
        generator.mockResults[6] = [2, 6, 4];
        Assert.same(
            [2, 6, 4],
            [for (die in roll.dice) die.result]
        );
    }
}