package dice.expressions;

import hscript.Expr;
import dice.macros.RollParsingMacros;
using StringTools;

/**
    Represents a complex expression, which may include any number of `SimpleRoll` expressions.

    e.g. `3d6 + 5`, `(2d3! * 3) - 2d4k1`

    The functions: `max`, `min`, `floor`, `ceil`, `round`, `abs` are also available in expressions.

    e.g. `max(2d20k, 3d6)` will compare the highest of 2 `d20` rolls with the sum of 3 `d6` rolls, and return the highest.

    These expressions are powered by hscript, so simple haxe style expressions are also permitted:

    e.g. `[for (i in 0...d6) d3]` would roll a `d6`, then roll a `d3` that many times, and return a list of the results.

    @see `SimpleRoll`
**/
class ComplexExpression {
    static inline final NULL_STRING : String = "null";
    var manager : RollManager;
    var expression : String;
    var parsedExpression : String;
    /**
        Array of all rolls made by this expression
    **/
    public var rolls : Array<SimpleRoll> = [];

    var storedResult : Null<Any>;

    var program : Null<Expr>;

    /**
        Log entries returned by calls to `log()` in the expression (and each roll if roll logging is enabled)
    **/
    public var logs : Array<String> = [];
    var logRolls : Bool;

    var executor : ComplexExpression -> Any;

    /**
        Results summary of every result this expression has yielded in each invocation of `roll()`
    **/
    public var resultsSummary : ResultsSummary;

    @:allow(dice.RollManager)
    function new(manager: RollManager, expression: String, logRolls = false, ?nativeExecutor: ComplexExpression -> Any) {
        this.manager = manager;
        this.expression = expression;
        this.logRolls = logRolls;
        var program : Null<Expr>;
        var parsedExpression : String;
        var executor : ComplexExpression -> Any;
        try {
            parsedExpression = parseExpressionString(expression);
            executor = if (nativeExecutor == null) {
                var parser = new hscript.Parser();
                program = parser.parseString('function (self) {
                    ${expressionPreamble()}
                    $parsedExpression
                }');
                var interp = new ExpressionInterpreter([
                    "log" => @:nullSafety(Off) log,
                    "roll" => @:nullSafety(Off) rollFromParams
                ]);
                interp.execute(program);
            } else {
                nativeExecutor;
            }
        } catch (e) {
            throw new dice.errors.InvalidExpression('Unable to parse $expression');
        }
        this.executor = executor;
        this.parsedExpression = parsedExpression;
        this.resultsSummary = new ResultsSummary();
    }

    @:allow(dice.RollManager)
    static function parseExpressionString(expressionString : String) : String {
        final regexFlags = "gi";
        #if macro
            var matcher = new EReg(RollParsingMacros.doBuildSimpleRollExpression(false, true), regexFlags);
        #else
        var matcher = new EReg(RollParsingMacros.buildSimpleRollExpression(false, true), regexFlags);
        #end
        var parsedExpressionString = matcher.map(expressionString, m -> {
            var match = m.matched(0);
            var expr = buildSimpleRoll(match);
            return expr;
        });
        if (!parsedExpressionString.trim().endsWith(";")) {
            parsedExpressionString = '$parsedExpressionString;';
        }
        return parsedExpressionString;
    }

    @:allow(dice.RollManager)
    static function expressionPreamble() : String {
        var preamble = "";
        for (op in ["max", "min", "floor", "ceil", "round", "abs", "pow"]) {
            preamble = 'var $op = Math.$op;\n$preamble';
        }
        return preamble;
    }

    static function buildSimpleRoll(simpleRollString : String) : String {
        var parsed = SimpleRoll.parseExpression(simpleRollString);
        var params : Array<Any> = [
            parsed.sides,
            parsed.number,
            parsed.explode != null ? parsed.explode : NULL_STRING,
            parsed.penetrate,
            parsed.keepLowestNumber != null ? parsed.keepLowestNumber : NULL_STRING,
            parsed.keepHighestNumber != null ? parsed.keepHighestNumber : NULL_STRING
        ];
        var paramString = params.map(Std.string).join(",");
        return 'roll("$simpleRollString",[$paramString])';
    }

    @:allow(dice.RollManager)
    function rollFromParams(
        simpleExpression:String,
        params:Array<Any>
    ) : Int {
        @SuppressWarnings("checkstyle:MagicNumber")
        var newRoll : SimpleRoll = {
            sides: params[0],
            number: params[1],
            explode: params[2],
            penetrate: params[3],
            keepLowestNumber: params[4],
            keepHighestNumber: params[5],
            expression: simpleExpression,
            manager: manager
        };
        rolls.push(newRoll);
        if (logRolls) {
            log('[$simpleExpression]: $newRoll');
        }
        return newRoll.total;
    }

    /**
        Returns the computed result of the entire expression.
        Accessing the result for the first time will calculate it, and subsequent accesses will
        retrieve the same reseult.
    **/
    public var result(get, never) : Any;
    function get_result() : Any {
        if (storedResult == null) {
            storedResult = roll();
        }
        return storedResult;
    }

    /**
        Recalculate the result. Including the rolls, and all expression logic.
    **/
    public function roll() : Any {
        logs = [];
        storedResult = executeExpression();
        resultsSummary.addResult(storedResult);
        return storedResult;
    }

    function log(entry:String) : ComplexExpression {
        logs.push(entry);
        return this;
    }

    function executeExpression() : Any {
        rolls = [];
        return executor(this);
    }

    /**
        Returns a 3-level nested array, grouped by roll expressions, then individual dice,
        and finally individual re-rolls, extra rolls, etc.
        
        So e.g. `2d6! + 2d3k1` might result in something like:
        ```
        [ [[6,3],[4]], [[2],[3]] ]
        ```
        Which would evaluate to `13 + 3` = `16`
    **/
    public function unpackRawResults() : Array<Array<Array<Int>>> {
        return [
            for (roll in rolls) [
                for (die in roll.rolledDice) [
                    for (sub in die.dice) sub.result
                ]
            ]
        ];
    }

    /**
        Recursively calls `roll()` in batches of n, until the proximity between successive normalised result maps is less than the threshold.

        @see `ResultsSummary.proximity`

        @param n Size of the batches to roll between convergence threshold checks
        @param threshold Threshold below which the results are considered to have 'converged' and rolling will stop
        @param feedback (Optional) A callback which is passed the number of results on the summary and the latest proximity value. Called on each iteration. 
    **/
    public function rollUntilConvergence(n : Int = 10000, threshold : Float = 0.0005, ?feedback: (Int, Float) -> Void) : ComplexExpression {
        var proximity = Math.POSITIVE_INFINITY;
        var previousProximity = Math.POSITIVE_INFINITY;
        // Break the loop when the proximity is below the threshold twice in a row AND smaller than the previous time
        while (proximity > threshold || proximity > previousProximity || previousProximity > threshold) {
            var previous = resultsSummary.normalisedResultMap.copy();
            for (i in 0...n) {
                roll();
            }
            previousProximity = proximity;
            proximity = resultsSummary.proximity(previous);
            if (feedback != null) {
                feedback(resultsSummary.numberOfResults, proximity);
            }
        }
        return this;
    }
}