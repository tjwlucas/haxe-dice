package tests.cases.expressions;

import dice.errors.InvalidExpression;
import utest.Assert;
import tests.mock.RandomGeneratorMock;
import utest.Test;

class ComplexExpressionTest extends Test {
    var generator : RandomGeneratorMock;
    var manager : dice.RollManager;
    function setup() {
        generator = new RandomGeneratorMock();
        manager = new dice.RollManager(generator);
    }
    function specParseExpression() {
        var expression = manager.getComplexExpression('(3d6! / 2) + d4');

        @:privateAccess expression.parsedExpression == '(roll("3d6!") / 2) + roll("d4")';
        Assert.same(
            [],
            [for(v in expression.rolls) @:privateAccess v.expression]
        );

        // Test that expressions in quotations are ignored
        var expression = manager.getComplexExpression('"The result of the (3d6! / 2) + d4 roll is: " + (3d6! / 2) + d4');
        @:privateAccess expression.parsedExpression == '"The result of the (3d6! / 2) + d4 roll is: " + (roll("3d6!") / 2) + roll("d4")';
        

        // Test that expressions in quotations are ignored
        var expression = manager.getComplexExpression("'The result of the (3d6! / 2) + d4 roll is: ' + (3d6! / 2) + d4");
        @:privateAccess expression.parsedExpression == "'The result of the (3d6! / 2) + d4 roll is: ' + (roll(\"3d6!\") / 2) + roll(\"d4\")";
        
    }

    function specParseBadExpression() {
        Assert.raises(() -> {
            manager.getComplexExpression('(3d6! / 2 + d4');
        }, InvalidExpression);
    }

    @:depends(specParseExpression)
    function specExecuteExpression() {
        var expression = manager.getComplexExpression('(3d6! / 2) + d4');

        Assert.same(
            [],
            [for(v in expression.rolls) @:privateAccess v.expression]
        );

        generator.mock_results = [
            6 => [
                3,6,2,5,    // Used for the first 3d6!
                3,2,6,6,1   // Second 3d6!
            ],
            4 => [1,2,4,2]
        ];
        Assert.equals(9, expression.result);
        Assert.equals(9, expression.result);
        Assert.same(
            ['3d6!','d4'],
            [for(v in expression.rolls) @:privateAccess v.expression]
        );

        Assert.equals(11, expression.roll());
        Assert.equals(11, expression.result);
        Assert.same(
            ['3d6!','d4'],
            [for(v in expression.rolls) @:privateAccess v.expression]
        );

        var expression = manager.getComplexExpression('d4 == 4');
        Assert.isTrue(expression.result);
        var expression = manager.getComplexExpression('d4 > 2');
        Assert.isFalse(expression.result);

        
        generator.mock_results[20] = [15, 9];
        var expression = manager.getComplexExpression('
            var r = d20;
            if(r >= 12) {
                return "Above (or equal to) 12";
            } else {
                return "Below 12";
            }
        ');
        expression.roll();
        Assert.equals("Above (or equal to) 12", expression.result);
        Assert.equals("Below 12", expression.roll());

        generator.mock_results[4] = [3];
        var expression = manager.getComplexExpression('var value = d4; (value > 2) && (value < 4)');
        Assert.isTrue(expression.result);

        generator.mock_results[8] = [6,3,5];
        var expression = manager.getComplexExpression('[d8, d8, d8]');
        Assert.same([6,3,5], expression.result);
        Assert.same(
            ['d8', 'd8', 'd8'],
            [for(v in expression.rolls) @:privateAccess v.expression]
        );

        generator.mock_results[8] = [6,3,5];
        var expression = manager.getComplexExpression('[for(i in 0...3) d8]');
        Assert.same([6,3,5], expression.result);
        Assert.same(
            ['d8', 'd8', 'd8'],
            [for(v in expression.rolls) @:privateAccess v.expression]
        );

        generator.mock_results[3] = [2];
        var expression = manager.getComplexExpression("['one', 'two', 'three'][d3 - 1]");
        Assert.same("two", expression.result);

        generator.mock_results[3] = [2,1,3,2,1,3,1,2,1,2];
        var expression = manager.getComplexExpression("
            var stats = [0,0,0];
            for(i in 0...10) {
                stats[d3 - 1]++;
            }
            stats
        ");
        Assert.same([4,4,2],expression.result);
        generator.shouldBeDoneAll();
    }
}