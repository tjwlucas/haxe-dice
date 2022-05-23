package tests.cases.expressions;

import dice.RollManager;
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

    function newSummary() {
        return @:privateAccess new dice.expressions.ResultsSummary();
    }

    function specRawResultsSummaryFromExpression() {
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

    function specRawResultsSummary() {
        var summary = newSummary();
        for (i in [8, 8, 12, 9, 9, 11]) {
            @:privateAccess summary.addResult(i);
        }

        Assert.same(
            [8, 8, 12, 9, 9, 11],
            summary.rawResults
        );
    }

    function specIsNumericAndInteger() {
        var summary = newSummary();
        for (i in [8, 8, 12, 9, 9, 11]) {
            @:privateAccess summary.addResult(i);
        }
        Assert.isTrue(summary.isNumeric);

        var summary = newSummary();
        @:privateAccess summary.addResult("string");
        Assert.isFalse(summary.isNumeric);

        var summary = newSummary();
        @:privateAccess summary.addResult(3);
        @:privateAccess summary.addResult(23);
        // [3, 23] - All integers, so far
        Assert.isTrue(summary.isNumeric);
        Assert.isTrue(summary.isInteger);
        @:privateAccess summary.addResult(4.5);
        // [3, 23, 4.5] - Now, there's a Float, still numeric, but not integer
        Assert.isTrue(summary.isNumeric);
        Assert.isFalse(summary.isInteger);
        @:privateAccess summary.addResult(true);
        // [3, 23, 4.5, true] - Bool stops it being numeric, at all
        Assert.isFalse(summary.isNumeric);
        Assert.isFalse(summary.isInteger);
    }

    function specResultsSummaryMap() {
        var summary = newSummary();
        for (i in [8, 8, 12, 9, 9, 11]) {
            @:privateAccess summary.addResult(i);
        }

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

    function specUniqueResultsSummaryInt() {
        var testValues : Array<Any> = [8, 8, 12, 9, 9, 11];
        var summary = newSummary();
        for (i in testValues) {
            @:privateAccess summary.addResult(i);
        }

        summary.uniqueResults.length == 4;
        for (i in testValues) {
            Assert.contains(i, summary.uniqueResults);
        }

        Assert.same(
            [8, 9, 11, 12],
            summary.sortedUniqueResults
        );
    }

    function specUniqueResultsSummaryFloat() {
        var testValues : Array<Any> = [8.3, 8.3, 12, 9.1, 9, 11];
        var summary = newSummary();
        for (i in testValues) {
            @:privateAccess summary.addResult(i);
        }

        summary.uniqueResults.length == 5;
        for (i in testValues) {
            Assert.contains(i, summary.uniqueResults);
        }

        Assert.same(
            [8.3, 9, 9.1, 11, 12],
            summary.sortedUniqueResults
        );
    }

    function specUniqueResultsSummaryMixed() {
        var testValues : Array<Any> = ['some', 'value', true, false, 15, 15, 'value'];
        var summary = newSummary();
        for (i in testValues) {
            @:privateAccess summary.addResult(i);
        }

        summary.uniqueResults.length == 5;
        for (i in testValues) {
            Assert.contains(i, summary.uniqueResults);
        }

        // 'Order' is not defined, so return the unique list unaltered
        Assert.same(summary.sortedUniqueResults, summary.uniqueResults);

        var emptyMap : Map<Int, Int> = [];
        Assert.same(emptyMap, summary.resultsMap);
    }

    function specResultsSummaryIntWithNull() {
        var testValues : Array<Any> = [8, 8, 12, 9, null, 9, 11];
        var summary = newSummary();
        for (i in testValues) {
            @:privateAccess summary.addResult(i);
        }

        Assert.isTrue(summary.includesNullValues);
        Assert.notContains(null, summary.rawResults);

        summary.uniqueResults.length == 4;
        for (i in testValues) {
            if (i != null) {
                Assert.contains(i, summary.uniqueResults);
            }
        }

        Assert.notContains(null, summary.uniqueResults);

        Assert.same(
            [8, 9, 11, 12],
            summary.sortedUniqueResults
        );

        summary.rawResults.length == 6;
        summary.numberOfResults == 7;
        Assert.isTrue(summary.isInteger);
        Assert.isTrue(summary.isNumeric);

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
            8 => 2 / 7,
            9 => 2 / 7,
            11 => 1 / 7,
            12 => 1 / 7
        ];
        Assert.same(
            expectedMap,
            summary.normalisedResultMap
        );
    }

    function specConvergenceWithCallback() {
        var randomManager = new RollManager();
        var targetProximity = 0.005;
        var rollCount : Int;
        var prox : Float;
        var expression = randomManager.getComplexExpression("2d6").rollUntilConvergence(1000, targetProximity, (n, e) -> {
            rollCount = n;
            prox = e;
        });

        prox < targetProximity;

        var summary = expression.resultsSummary;

        summary.numberOfResults == rollCount;

        var map = summary.normalisedResultMap;

        var keys = [for (k in map.keys()) k];
        keys.length == 11;

        for (i in [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]) {
            Assert.contains(i, keys);

            // Once converged, should follow the general shape of increasing probability up to a max result of 7, then decreasing
            if (i < 7) {
                map[i] < map[i + 1];
            } else if (i < 12) {
                map[i] > map[i + 1];
            }
        }
    }

    function specConvergenceWithoutCallback() {
        var randomManager = new RollManager();
        var expression = randomManager.getComplexExpression("d6").rollUntilConvergence(10000, 0.0005);

        var summary = expression.resultsSummary;
        var map = summary.normalisedResultMap;

        var keys = [for (k in map.keys()) k];
        keys.length == 6;

        var expected = 1 / 6;

        for (i in [1, 2, 3, 4, 5, 6]) {
            Assert.contains(i, keys);
            // Allow a fairly large deviation from the expected
            map[i] < expected + 0.01;
            map[i] > expected - 0.01;
        }
    }
}