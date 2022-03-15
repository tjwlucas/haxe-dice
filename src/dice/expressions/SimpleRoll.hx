package dice.expressions;

class SimpleRoll {
    public var sides : Int;
    public var number : Int;

    private var expression : String;

    var manager : Null<RollManager>;

    var stored_dice : Null<Array<Die>>;
    var explode : Null<Int>;

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
        this.expression = expression;
        try {
            var basic = parseCoreExpression(expression);
            number = basic.number != null ? basic.number : 1;
            sides = basic.sides;
            explode = getModifier('!');
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
        Get modifier value for given modifier. If requested modifier is present, but with no number, defaults to 1.
        Returns null if modifier not present.
        @param mod Parameter key. e.g. The modifier "k" on the expression "4d6k2" would return 2.
    
    **/
    public function getModifier(mod: String) : Null<Int> {
        // Allow a single character alphabetic modifier, or !
        var allowed_modifier = ~/^[a-z!]$/;
        if(!allowed_modifier.match(mod)) {
            throw new dice.errors.InvalidModifier('$mod Is not a valid modifier');
        }
        var core_matcher = new EReg("\\d*d[a-z0-9!]*(" + mod + ")(\\d*)", "i");
        var is_matched = core_matcher.match(expression);
        if(!is_matched) {
            return null;
        }
        var multimatcher =  new EReg("\\d*d[a-z0-9!]*" + mod + "\\d*[a-z0-9!]*" + mod + "\\d*", "i");
        var multiple_matches = multimatcher.match(expression);
        if (multiple_matches) {
            throw new dice.errors.InvalidExpression('$expression contains the $mod modifier more than once');
        }
        var number = Std.parseInt(core_matcher.matched(2));
        if (number == null) {
            if(mod == '!') {
                number = sides;
            } else {
                number = 1;
            }
        }
        return number;
    }

    /**
        Will (re-)roll all dice attached to this 'roll' object
    **/
    public function roll() : SimpleRoll {
        stored_dice = [for (i in 0...number) manager.getDie(sides, explode)];
        for (die in stored_dice) {
            die.roll();
        }
        return this;
    }

    public var dice(get, never) : Array<Die>;
    function get_dice() : Array<Die> {
        if(stored_dice != null) {
            return stored_dice;
        }
        else {
            roll();
            return stored_dice;
        }
    };

    public var total(get, never) : Int;
    function get_total() : Int {
        var total = 0;
        for (die in dice) {
            total += die.result;
        }
        return total;
    };

    function keep_highest(n:Int) : SimpleRoll {
        // Sort highest result to lowest
        dice.sort((a,b) -> {
            b.result - a.result;
        });
        stored_dice = dice.slice(0, n);
    }
}