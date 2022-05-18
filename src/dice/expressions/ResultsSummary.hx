package dice.expressions;

class ResultsSummary {
    public var rawResults : Array<Any> = [];
    public var numberOfResults : Int = 0;

    /**
        Should be true if *every* result is numeric (Float or Int), otherwise false.
        
        (true when there are no results, yet - numeric until proven otherwise)
    **/
    public var isNumeric : Bool = true;

    public var includesNullValues : Bool = false;

    public var resultsMap : Map<Any, Int> = [];

    public var normalisedResultMap(get, never) : Map<Any, Float>;
    function get_normalisedResultMap() : Map<Any, Float> {
        var normMap : Map<Any, Float> = [];
        for (key => value in resultsMap) {
            normMap[key] = value / numberOfResults;
        }
        return normMap;
    }

    public var uniqueResults(get, never) : Array<Any>;
    function get_uniqueResults() : Array<Any> {
        var unique = [for (key in resultsMap.keys()) key];
        if (isNumeric) {
            unique = unique.map(value -> Std.parseFloat(value));
            unique.sort((a:Any, b:Any) -> (a:Int) - (b:Int) );
        }
        return unique;
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
        }
        rawResults.push(result);

        resultsMap[result] = switch (resultsMap.get(result)) {
            case null: 1;
            case count: count + 1;
        }
    }
}