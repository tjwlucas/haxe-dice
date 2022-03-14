package dice.expressions;

class SimpleRoll {
    public var sides : Int;
    public var number : Int;

    var manager : Null<RollManager>;

    var stored_dice : Null<Array<RawDie>>;

    public function new(manager: RollManager, ?expression: String) {
        this.manager = manager;
        if(expression != null) {
            this.parse(expression);
        }
    }

    /**
        @param expression A 'simple' die-notation style expression (a single roll). Such as `2d6`, `3d4`, `d20`
        @throws dice.errors.InvalidExpression When passed an invalid expression
    **/
    public function parse(expression : String) : SimpleRoll {
        try {
            var basic = parseCoreExpression(expression);
            number = basic.number != null ? basic.number : 1;
            sides = basic.sides;
            return this;
        } catch(e) {
            throw new dice.errors.InvalidExpression('$expression is not a valid core die expression');
        }
    }

    /**
        Parse only the basic XdY portion of the die expression
    **/
    static function parseCoreExpression(expression : String) {
        var core_matcher = ~/^(\d*)d(\d+)/i;
        var is_matched = core_matcher.match(expression);
        if(!is_matched) {
            throw new dice.errors.InvalidExpression('$expression is not a valid core die expression');
        }
        var number = Std.parseInt(core_matcher.matched(1));
        var sides = Std.parseInt(core_matcher.matched(2));
        return {
            number: number,
            sides: sides
        }
    }

    /**
        Will (re-)roll all dice attached to this 'roll' object
    **/
    public function roll() : SimpleRoll {
        stored_dice = [for (i in 0...number) manager.getRawDie(sides)];
        for (die in stored_dice) {
            die.roll();
        }
        return this;
    }

    public var dice(get, never) : Array<RawDie>;
    function get_dice() : Array<RawDie> {
        if(stored_dice != null) {
            return stored_dice;
        }
        else {
            roll();
            return stored_dice;
        }
    };
}