package tests.cases.expressions;

import tests.mock.RandomGeneratorMock;
import utest.Assert;
import utest.Test;

using dice.expressions.SimpleRoll;

class ResultsSummaryTest extends Test {
    var generator : RandomGeneratorMock;
    var manager : dice.RollManager;
    function setup() {
        generator = new RandomGeneratorMock();
        manager = new dice.RollManager(generator);
    }

    function specRawResultsSummary() {
        generator.mockResults[6] = [2, 3, 1, 4, 3, 6, 2, 4, 1, 5, 6, 2];
        var expression = manager.getComplexExpression("2d6 + 3");
        for (i in 0...6) {
            expression.roll();
        }
        var summary = expression.resultsSummary;

        Assert.same(
            [8, 8, 12, 9, 9, 11],
            summary.rawResults
        );
    }

    function specIsNumericAndInteger() {
        generator.mockResults[6] = [2, 3, 1, 4, 3, 6, 2, 4, 1, 5, 6, 2];
        var expression = manager.getComplexExpression("2d6 + 3");
        for (i in 0...6) {
            expression.roll();
        }
        var summary = expression.resultsSummary;
        Assert.isTrue(summary.isNumeric);

        var expression = manager.getComplexExpression("'string'");
        expression.roll();
        var summary = expression.resultsSummary;
        Assert.isFalse(summary.isNumeric);

        generator.mockResults[4] = [1, 2, 3, 4];
        var expression = manager.getComplexExpressionRuntime("[3, 23, 4.5, true][d4 - 1]");
        for (i in 0...2) {
            expression.roll();
        }
        var summary = expression.resultsSummary;
        // [3, 23] - All integers, so far
        Assert.isTrue(summary.isNumeric);
        Assert.isTrue(summary.isInteger);
        expression.roll();
        // [3, 23, 4.5] - Now, there's a Float, still numeric, but not integer
        Assert.isTrue(summary.isNumeric);
        Assert.isFalse(summary.isInteger);
        expression.roll();
        // [3, 23, 4.5, true] - Bool stops it being numeric, at all
        Assert.isFalse(summary.isNumeric);
        Assert.isFalse(summary.isInteger);
    }

    function specResultsSummaryMap() {
        generator.mockResults[6] = [2, 3, 1, 4, 3, 6, 2, 4, 1, 5, 6, 2];
        var expression = manager.getComplexExpression("2d6 + 3");
        for (i in 0...6) {
            expression.roll();
        }
        var summary = expression.resultsSummary;

        var expectedMap : Map<Int, Int> = [
            8 => 2,
            9 => 2,
            11 => 1,
            12 => 1
        ];
        Assert.same(
            expectedMap,
            summary.resultsMap
        );

        var expectedMap : Map<Int, Float> = [
            8 => 1 / 3,
            9 => 1 / 3,
            11 => 1 / 6,
            12 => 1 / 6
        ];
        Assert.same(
            expectedMap,
            summary.normalisedResultMap
        );
    }

    function specUniqueResultsSummary() {
        generator.mockResults[6] = [2, 3, 1, 4, 3, 6, 2, 4, 1, 5, 6, 2];
        var expression = manager.getComplexExpression("2d6 + 3");
        for (i in 0...6) {
            expression.roll();
        }
        var summary = expression.resultsSummary;

        Assert.same(
            [8, 9, 11, 12],
            summary.uniqueResults
        );
    }
}