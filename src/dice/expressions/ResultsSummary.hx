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
            unique.sort((a, b) -> a - b);
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

    @:allow(dice.expressions.ComplexExpression)
    function new() {}

    @:allow(dice.expressions.ComplexExpression.roll)
    function addResult(result:Any) : Void {
        numberOfResults++;
        if (result == null) {
            includesNullValues = true;
        } else {
            isNumeric = switch [isNumeric, Std.isOfType(result, Float)] {
                case [false, _]: false;
                case [true, true]: true;
                default: false;
            }
            isInteger = switch [isInteger, Std.isOfType(result, Int)] {
                case [false, _]: false;
                case [true, true]: true;
                default: false;
            }
            if (isInteger) {
                var numericResult : Int = result;
                var oldCount = resultsMap.exists(numericResult) ? resultsMap.get(numericResult) : 0;
                resultsMap.set(numericResult, oldCount + 1);
            }
        }
        rawResults.push(result);

    }
}