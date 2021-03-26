package tests.cases.expressions;

import dice.errors.InvalidExpression;
import utest.Assert;
import dice.expressions.SimpleRoll;
import utest.Test;

class SimpleRollTest extends Test {
    function specBasicParse() {
        var roll_expression = SimpleRoll.parse('d6');
        roll_expression.sides == 6;
        roll_expression.number == 1;

        var roll_expression = SimpleRoll.parse('3d20');
        roll_expression.sides == 20;
        roll_expression.number == 3;

        var roll_expression = SimpleRoll.parse('3D20');
        roll_expression.sides == 20;
        roll_expression.number == 3;

        Assert.raises(() -> {
            SimpleRoll.parse('invalid');
        }, InvalidExpression);

        var roll_expression = SimpleRoll.parse('d45q');
        roll_expression.sides == 45;
        roll_expression.number == 1;

        Assert.raises(() -> {
            SimpleRoll.parse('asdd45q');
        }, InvalidExpression);

        Assert.raises(() -> {
            SimpleRoll.parse('45q');
        }, InvalidExpression);
    }
}