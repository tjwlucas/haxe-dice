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

        @:privateAccess expression.parsedExpression == '((rolls[0].total) / 2) + (rolls[1].total)';
        Assert.same(
            ['3d6!','d4'],
            [for(v in @:privateAccess expression.rolls) @:privateAccess v.expression]
        );
    }

    function specParseBadExpression() {
        Assert.raises(() -> {
            manager.getComplexExpression('(3d6! / 2 + d4');
        }, InvalidExpression);
    }

    @:depends(specParseExpression)
    function specExecuteExpression() {
        var expression = manager.getComplexExpression('(3d6! / 2) + d4');

        generator.mock_results = [
            6 => [
                3,6,2,5,    // Used for the first 3d6!
                3,2,6,6,1   // Second 3d6!
            ],
            4 => [1,2]
        ];
        expression.result == 9;
        expression.result == 9;
        expression.roll() == 11;
        expression.result == 11;
    }
}