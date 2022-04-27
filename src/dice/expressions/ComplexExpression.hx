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
        var matcher = new EReg(RollParsingMacros.buildSimpleRollExpression(false), 'gi');
        var i = 0;
        parsedExpression = matcher.map(expression, (m) -> {
            var match = m.matched(0);
            var expr = '(roll("$match"))';
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

    public var result(get, never) : Dynamic;
    public function get_result() : Dynamic {
        if(stored_result == null) {
            roll();
        } 
        return stored_result;
    }
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
}