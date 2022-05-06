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

        
        // Allow for multipleinstances of modifiers across *different* subexpressions
        var expression = manager.getComplexExpression('(3d6! / 2) + d4!');
        @:privateAccess expression.parsedExpression == '(roll("3d6!") / 2) + roll("d4!")';
    }

    function specParseBadExpression() {
        Assert.raises(() -> manager.getComplexExpression('(3d6! / 2 + d4'), InvalidExpression);

        Assert.raises(() -> manager.getComplexExpression('2d6!x + 3'), InvalidExpression);

        Assert.raises(() -> manager.getComplexExpression('2d6kl + 3'), InvalidExpression);

        Assert.raises(() -> manager.getComplexExpression('5d6k2l1 + 3'), InvalidExpression);
    }

    @:depends(specParseExpression)
    function specExecuteExpression() {
        var expression = manager.getComplexExpression('(3d6! / 2) + d4');

        Assert.same(
            [],
            [for(v in expression.rolls) @:privateAccess v.expression]
        );

        generator.mockResults = [
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

        
        generator.mockResults[20] = [15, 9];
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

        generator.mockResults[4] = [3];
        var expression = manager.getComplexExpression('var value = d4; (value > 2) && (value < 4)');
        Assert.isTrue(expression.result);

        generator.mockResults[8] = [6,3,5];
        var expression = manager.getComplexExpression('[d8, d8, d8]');
        Assert.same([6,3,5], expression.result);
        Assert.same(
            ['d8', 'd8', 'd8'],
            [for(v in expression.rolls) @:privateAccess v.expression]
        );

        generator.mockResults[8] = [6,3,5];
        var expression = manager.getComplexExpression('[for(i in 0...3) d8]');
        Assert.same([6,3,5], expression.result);
        Assert.same(
            ['d8', 'd8', 'd8'],
            [for(v in expression.rolls) @:privateAccess v.expression]
        );

        generator.mockResults[3] = [2];
        var expression = manager.getComplexExpression("['one', 'two', 'three'][d3 - 1]");
        Assert.same("two", expression.result);

        generator.mockResults[3] = [2,1,3,2,1,3,1,2,1,2];
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

    function specUnpackRawResults() {
        generator.mockResults = [
            6 => [3,6,2,5],
            4 => [4,2]
        ];

        var expression = manager.getComplexExpression('3d6! + 2d4');
        expression.roll();

        Assert.same(
            [
                [
                    [3],
                    [6,2],
                    [5]
                ],
                [
                    [4],
                    [2]
                ]
            ],
            expression.unpackRawResults()
        );


        generator.mockResults = [
            6 => [3,6,2,5],
            4 => [4,2],
            3 => [3,2,1,2]
        ];

        var expression = manager.getComplexExpression('3d6!k + d4! + 3d3!l2');
        Assert.equals(17, expression.roll());

        Assert.same(
            [
                [
                    [3],
                    [6,2],
                    [5]
                ],
                [
                    [4,2]
                ],
                [
                    [3,2],
                    [1],
                    [2]
                ]
            ],
            expression.unpackRawResults()
        );

    }

    function specOperations() {
        var expression = manager.getComplexExpression('3 ^ 2');
        Assert.equals(9, expression.roll());

        var expression = manager.getComplexExpression('floor(3 / 2)');
        Assert.equals(1, expression.roll());

        var expression = manager.getComplexExpression('ceil(3 / 2)');
        Assert.equals(2, expression.roll());

        var expression = manager.getComplexExpression('round(3 / 2)');
        Assert.equals(2, expression.roll());

        generator.mockResults = [
            6 => [3],
            3 => [2]
        ];

        var expression = manager.getComplexExpression('d6 ^ d3');
        Assert.equals(9, expression.roll());

        var expression = manager.getComplexExpression('max(d6, d3!)');
        generator.mockResults = [
            6 => [4],
            3 => [3,3,1]
        ];
        Assert.equals(7, expression.roll());

        var expression = manager.getComplexExpression('min(d6, d3!)');
        generator.mockResults = [
            6 => [4],
            3 => [3,3,1]
        ];
        Assert.equals(4, expression.roll());

        var expression = manager.getComplexExpression('floor(max(d6,d3!)/d6)');
        generator.mockResults = [
            6 => [4, 2],
            3 => [3,3,1]
        ];
        Assert.equals(3, expression.roll());

        var expression = manager.getComplexExpression('abs(2d6 - 2d6)');
        generator.mockResults = [
            6 => [1,3,6,4]
        ];
        Assert.equals(6, expression.roll());
    }

    function specLogs() {
        generator.mockResults = [
            6 => [3,6,2,5],
            4 => [4,2],
            3 => [3,2,1,2]
        ];
        var expression = manager.getComplexExpression('3d6!k + d4! + 3d3!l2', true);
        expression.roll();
        Assert.same([
            '[3d6!k]: 3, 6+2, 5',
            '[d4!]: 4+2',
            '[3d3!l2]: 3+2, 1, 2'
        ], expression.logs);


        generator.mockResults = [
            6 => [3,4,6,5,1,5]
        ];
        var expression = manager.getComplexExpression('
            var count = 0;
            for(i in 0...6) {
                var r = d6;
                if(r >= 4) {
                    log(r + " is >= 4");
                    count++;
                }
            }
            count;
        ', true);
        expression.roll();
        Assert.same([
            '[d6]: 3',
            '[d6]: 4',
            '4 is >= 4',
            '[d6]: 6',
            '6 is >= 4',
            '[d6]: 5',
            '5 is >= 4',
            '[d6]: 1',
            '[d6]: 5',
            '5 is >= 4',
        ], expression.logs);
        Assert.equals(4, expression.result);

        // With roll logging off
        generator.mockResults = [
            6 => [3,4,6,5,1,5]
        ];
        var expression = manager.getComplexExpression('
            var count = 0;
            for(i in 0...6) {
                var r = d6;
                if(r >= 4) {
                    log(r + " is >= 4");
                    count++;
                }
            }
            count;
        ');
        expression.roll();
        Assert.same([
            '4 is >= 4',
            '6 is >= 4',
            '5 is >= 4',
            '5 is >= 4',
        ], expression.logs);
        Assert.equals(4, expression.result);
    }
}