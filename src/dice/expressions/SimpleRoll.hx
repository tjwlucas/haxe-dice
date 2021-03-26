package dice.expressions;

@:structInit class SimpleRoll {
    public var sides : Int;
    public var number : Int = 1;
    public static function parse(expression : String) : SimpleRoll {
        try {
            var basic = parseCoreExpression(expression);
            return {
                number: basic.number,
                sides: basic.sides
            }
        } catch(e) {
            throw new dice.errors.InvalidExpression('$expression is not a valid core die expression');
        }
    }

    /**
        Parse only the basic XdY portion of the die expression
    **/
    static function parseCoreExpression(expression : String) {
        var core_matcher = ~/^(\d*)d(\d+)/i;
        core_matcher.match(expression);
        var number = Std.parseInt(core_matcher.matched(1));
        var sides = Std.parseInt(core_matcher.matched(2));
        return {
            number: number,
            sides: sides
        }
    }
}