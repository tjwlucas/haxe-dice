package dice.expressions;

import hscript.Expr;
import dice.macros.RollParsingMacros;

class ComplexExpression {
    var manager : RollManager;
    var expression : String;
    var parsedExpression : String;
    public var rolls : Array<SimpleRoll> = [];

    var stored_result : Dynamic;

    var program : Expr;

    public function new(manager: RollManager, expression: String) {
        this.manager = manager;
        this.expression = expression;
        this.parse();
    }

    private function parse() {
        var matcher = new EReg(RollParsingMacros.buildSimpleRollExpression(false, true), 'gi');
        var i = 0;
        parsedExpression = matcher.map(expression, (m) -> {
            var match = m.matched(0);
            var expr = 'roll("$match")';
            i++;
            return expr;
        });

        try {
            var parser = new hscript.Parser();
            program = parser.parseString(parsedExpression);
        } catch(e) {
            throw new dice.errors.InvalidExpression('Unable to parse $expression');
        }
    }

    /**
        Returns the computed result of the entire expression.
        Accessing the result for the first time will calculate it, and subsequent accesses will
        retrieve the same reseult.
    **/
    public var result(get, never) : Dynamic;
    public function get_result() : Dynamic {
        if(stored_result == null) {
            roll();
        } 
        return stored_result;
    }

    /**
        Recalculate the result. Including the rolls, and all expression logic.
    **/
    public function roll() {
        stored_result = executeExpression();
        return stored_result;
    }

    function rollFromSimpleExpression(expression:String) {
        var newRoll = manager.getSimpleRoll(expression);
        rolls.push(newRoll);
        return newRoll.total;
    }

    function executeExpression() {
        var interp = new hscript.Interp();
        rolls = [];
        interp.variables.set("roll",rollFromSimpleExpression);
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
    public function unpackRawResults() {
        return [
            for(roll in rolls) [
                for(die in roll.rolled_dice) [
                    for(sub in die.dice) sub.result
                ]
            ]
        ];
    }
}