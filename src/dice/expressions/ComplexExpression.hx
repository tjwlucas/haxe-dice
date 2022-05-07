package dice.expressions;

import hscript.Expr;
import dice.macros.RollParsingMacros;

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
    var manager : RollManager;
    var expression : String;
    var parsedExpression : String;
    /**
        Array of all rolls made by this expression
    **/
    public var rolls : Array<SimpleRoll> = [];

    var storedResult : Null<Any>;

    var program : Expr;

    /**
        Log entries returned by calls to `log()` in the expression (and each roll if roll logging is enabled)
    **/
    public var logs : Array<String> = [];
    var logRolls : Bool;

    @:allow(dice.RollManager)
    function new(manager: RollManager, expression: String, logRolls = false) {
        this.manager = manager;
        this.expression = expression;
        this.logRolls = logRolls;
        var program : Expr;
        var parsedExpression : String;
        try {
            parsedExpression = parseExpressionString(expression);
            var parser = new hscript.Parser();
            program = parser.parseString(parsedExpression);
        } catch (e) {
            throw new dice.errors.InvalidExpression('Unable to parse $expression');
        }
        this.parsedExpression = parsedExpression;
        this.program = program;
    }

    static function parseExpressionString(expressionString : String) : String {
        var matcher = new EReg(RollParsingMacros.buildSimpleRollExpression(false, true), "gi");
        return matcher.map(expressionString, m -> {
            var match = m.matched(0);
            var expr = buildSimpleRoll(match);
            return expr;
        });
    }

    static function buildSimpleRoll(simpleRollString : String) : String {
        var parsed = SimpleRoll.parseExpression(simpleRollString);
        var params : Array<Any> = [
            parsed.sides,
            parsed.number,
            parsed.explode,
            parsed.penetrate,
            parsed.keepLowestNumber,
            parsed.keepHighestNumber
        ];
        var paramString = params.map(Std.string).join(",");
        return 'roll("$simpleRollString",$paramString)';
    }

    function rollFromParams(
        simpleExpression:String,
        sides:Int,
        number:Int,
        explode:Null<Int>,
        penetrate:Bool,
        keepLowest:Null<Int>,
        keepHighest:Null<Int>
    ) : Int {
        var newRoll : SimpleRoll = {
            sides: sides,
            number: number,
            explode: explode,
            penetrate: penetrate,
            keepLowestNumber: keepLowest,
            keepHighestNumber: keepHighest,
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
        return storedResult;
    }

    function log(entry:String) : ComplexExpression {
        logs.push(entry);
        return this;
    }

    function executeExpression() : Any {
        var interp = new ExpressionInterpreter([
            "log" => log,
            "roll" => rollFromParams
        ]);
        rolls = [];
        return interp.execute(program);
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
}