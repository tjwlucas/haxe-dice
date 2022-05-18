package dice.expressions;

class ResultsSummary {
    public var rawResults : Array<Any> = [];
    public var numberOfResults : Int = 0;

    /**
        Should be true if *every* result is numeric (Float or Int), otherwise false.
        
        (true when there are no results, yet - numeric until proven otherwise)
    **/
    public var isNumeric : Bool = true;

    public var isInteger : Bool = true;

    public var includesNullValues : Bool = false;

    public var resultsMap(get, default) : Map<Int, Int> = [];
    function get_resultsMap() : Map<Int, Int> {
        return if (isInteger) {
            resultsMap;
        } else {
            [];
        }
    }

    public var normalisedResultMap(get, never) : Map<Int, Float>;
    function get_normalisedResultMap() : Map<Int, Float> {
        var normMap : Map<Int, Float> = [];
        for (key => value in resultsMap) {
            normMap[key] = value / numberOfResults;
        }
        return normMap;
    }

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
}