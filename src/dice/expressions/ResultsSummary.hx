package dice.expressions;

class ResultsSummary {
    var rawResults : Array<Any> = [];
    var numberOfResults : Int = 0;

    /**
        Should be true if *every* result is numeric (Float or Int), otherwise false. (Null when there are no results, yet)
    **/
    var isNumeric : Null<Bool>;

    var minResult : Null<Float>;
    var maxResult : Null<Float>;

    @:allow(dice.expressions.ComplexExpression)
    function new() {}

    @:allow(dice.expressions.ComplexExpression.roll)
    function addResult(result:Any) : Void {
        numberOfResults++;
        isNumeric = switch [isNumeric, Std.isOfType(result, Float)] {
            case [false, _]: false;
            case [true, true]: true;
            default: false;
        }
        if (isNumeric) {
            var newResult : Float = result;

            if (minResult == null || newResult < minResult) {
                minResult = newResult;
            }

            if (maxResult == null || newResult > maxResult) {
                maxResult = newResult;
            }
        }
        rawResults.push(result);
    }
}