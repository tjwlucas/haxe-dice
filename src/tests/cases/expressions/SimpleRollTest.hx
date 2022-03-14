package tests.cases.expressions;

import tests.mock.RandomGeneratorMock;
import dice.errors.InvalidExpression;
import utest.Assert;
import dice.expressions.SimpleRoll;
import utest.Test;

class SimpleRollTest extends Test {
    var generator : RandomGeneratorMock;
    var manager : dice.RollManager;
    var simpleRoll : SimpleRoll;
    function setup() {
        generator = new RandomGeneratorMock();
        manager = new dice.RollManager(generator);
        simpleRoll = manager.getSimpleRoll();
    }

    function specBasicParse() {
        var roll_expression = simpleRoll.parse('d6');
        roll_expression.sides == 6;
        roll_expression.number == 1;

        var roll_expression = simpleRoll.parse('3d20');
        roll_expression.sides == 20;
        roll_expression.number == 3;

        var roll_expression = simpleRoll.parse('3D20');
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
}