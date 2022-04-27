package dice.expressions;

import hscript.Expr;
import dice.macros.RollParsingMacros;

class ComplexExpression {
    var manager : RollManager;
    var expression : String;
    var parsedExpression : String;
    var rolls : Array<SimpleRoll> = [];

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
            rolls[i] = manager.getSimpleRoll(match);
            var expr = '(rolls[$i].total)';
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
        for(roll in rolls) {
            roll.roll();
        }
        stored_result = executeExpression();
        return stored_result;
    }

    function executeExpression() {
        var interp = new hscript.Interp();
        interp.variables.set("rolls",rolls);
        return interp.execute(program);
    }
}