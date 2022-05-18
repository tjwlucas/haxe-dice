package dice.expressions;

/**
    Results summary of every result this expression has yielded in each invocation of `roll()`
**/
class ResultsSummary {
    /**
        Raw list of all results added to the results summary set (excluding null values)
    **/
    public var rawResults : Array<Any> = [];

    /**
        Total count of results that have been added to the summary set. (Including null values)
    **/
    public var numberOfResults : Int = 0;

    /**
        Should be true if *every* result is numeric (Float or Int), otherwise false.
        
        (true when there are no results, yet - numeric until proven otherwise)
    **/
    public var isNumeric : Bool = true;

    /**
        Should be true if *every* result is an integer, otherwise false.
        
        (true when there are no results, yet - integer until proven otherwise)
    **/
    public var isInteger : Bool = true;

    /**
        Returns true if at least one null result has been added to the result set
    **/
    public var includesNullValues : Bool = false;

    /**
        If *all* results in the set are integers, returns a frequency map of each result.

        e.g. A raw set of `[1,3,4,3,5,2,1]` would yield a `resultsMap` of:

        ```
        [
            1 => 2,
            2 => 1,
            3 => 2,
            4 => 1,
            5 => 1
        ]
        ```
    **/
    public var resultsMap(get, default) : Map<Int, Int> = [];
    function get_resultsMap() : Map<Int, Int> {
        return if (isInteger) {
            resultsMap;
        } else {
            [];
        }
    }

    /**
        Similar to `resultsMap` but returns normalised results (each value is divided by the `numberOfResults`)
    **/
    public var normalisedResultMap(get, never) : Map<Int, Float>;
    function get_normalisedResultMap() : Map<Int, Float> {
        var normMap : Map<Int, Float> = [];
        for (key => value in resultsMap) {
            normMap[key] = value / numberOfResults;
        }
        return normMap;
    }

    /**
        A deduplicated list of all results
    **/
    public var uniqueResults(get, never) : Array<Any>;
    function get_uniqueResults() : Array<Any> {
        if (isInteger) {
            var unique = [for (key in resultsMap.keys()) key];
            return unique;
        } else {
            var unique : Array<Any> = [];
            for (r in rawResults) {
                if (!unique.contains(r)) {
                    unique.push(r);
                }
            }
            return unique;
        }
    }

    /**
        As `uniqueResults`, but (if numeric) sorted in ascending order. If non-numeric, simply returns `uniqueResults` unchanged.
    **/
    public var sortedUniqueResults(get, never) : Array<Any>;
    function get_sortedUniqueResults() : Array<Any> {
        if (isNumeric) {
            return if (isInteger) {
                var sorted : Array<Int> = cast uniqueResults;
                sorted.sort((a, b) -> a - b);
                sorted;
            } else {
                var sorted : Array<Float> = cast uniqueResults;
                sorted.sort((a, b) -> {
                    return a > b ? 1 : -1; // Don't need to worry about the equal case, since this is already a unique list
                });
                sorted;
            }
        } else {
            return uniqueResults;
        }
    }

    @:allow(dice.expressions.ComplexExpression)
    function new() {}

    @:allow(dice.expressions.ComplexExpression.roll)
    function addResult(result:Any) : Void {
        numberOfResults++;
        if (result == null) {
            includesNullValues = true;
        } else {
            inline function allMatchType(result : Any, existing : Bool, type : Any) : Bool {
                return switch [existing, Std.isOfType(result, type)] {
                    case [false, _]: false;
                    case [true, true]: true;
                    default: false;
                }
            }

            isNumeric = allMatchType(result, isNumeric, Float);
            isInteger = allMatchType(result, isInteger, Int);

            if (isInteger) {
                var numericResult : Int = result;
                var oldCount = resultsMap.get(numericResult);
                resultsMap.set(numericResult, oldCount != null ? oldCount + 1 : 1);
            }
            rawResults.push(result);
        }

    }

    /**
        Measure the 'proximity' between the current result set and a provided `normalisedResultMap`. 
        The measure is defined as the largest difference between the normalised results for each key
        (if the key is missing from the previous map, this 'differnece' is just the value on the new map)
    **/
    @:allow(dice.expressions.ComplexExpression.rollUntilConvergence)
    function proximity(compared:Map<Int, Float>) : Float {
        var maxDiff : Float = 0;
        for (key => value in normalisedResultMap) {
            var oldValue : Float = cast compared.exists(key) ? compared.get(key) : 0;
            maxDiff = Math.max(maxDiff, Math.abs(value - oldValue));
        }
        return maxDiff;
    }
}