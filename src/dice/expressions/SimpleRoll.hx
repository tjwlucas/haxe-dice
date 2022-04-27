package dice.expressions;

import dice.util.Util;
import haxe.macro.Context;
import dice.enums.Modifier;
import dice.macros.RollParsingMacros;

class SimpleRoll {
    public var sides : Int;
    public var number : Int;

    private var expression : String;

    var manager : Null<RollManager>;

    var stored_dice : Null<Array<Die>>;
    var explode : Null<Int>;
    var penetrate : Bool;
    var keep_highest_number : Null<Int>;
    var keep_lowest_number : Null<Int>;

    public var rolled_dice : Array<Die>;

    /**
        The general regex that will match a valid die expression
    **/
    static inline var MATCHING_STRING = RollParsingMacros.buildSimpleRollExpression();

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
            explode = getModifier(PENETRATE);
            if(explode == null) {
                explode = getModifier(EXPLODE);
                penetrate = false;
            } else {
                penetrate = true;
            }
            keep_highest_number = getModifier(KEEP_HIGHEST);
            keep_lowest_number = getModifier(KEEP_LOWEST);
            if(keep_highest_number != null) {
                if(keep_highest_number <= 0 || keep_highest_number > number) {
                    throw new dice.errors.InvalidExpression('Number of dice to keep must be between 1 and $number. ($keep_highest_number given)');
                }
                if(keep_lowest_number != null) {
                    throw new dice.errors.InvalidExpression('$expression invalid, can only keep highest or lowest');
                }
            }
            
            if(keep_lowest_number != null) {
                if(keep_lowest_number <= 0 || keep_lowest_number > number) {
                    throw new dice.errors.InvalidExpression('Number of dice to keep must be between 1 and $number. ($keep_lowest_number given)');
                }
            }
            return this;
        } catch(e) {
            throw new dice.errors.InvalidExpression('$expression is not a valid core die expression');
        }
    }

    /**
        Validates the provided expression and extracts the initial basic info (number of dice and number of sides)
    **/
    function parseCoreExpression(expression : String) {
        var matcher = new EReg(MATCHING_STRING, "i");
        if (matcher.match(expression)) {
            var number = Std.parseInt(matcher.matched(1));
            var sides = Std.parseInt(matcher.matched(2));
            return {
                number: number,
                sides: sides
            };
        } else {
            throw new dice.errors.InvalidExpression('$expression is not a valid core die expression');
        };
    }

    /**
        Get modifier value for given modifier. If requested modifier is present, but with no number, defaults to 1.
        Returns null if modifier not present.
        @param mod Parameter key. e.g. The modifier "k" on the expression "4d6k2" would return 2.
    
    **/
    function getModifier(mod: Modifier) : Null<Int> {
        var matcher = new EReg(Util.constructMatcher(mod), "i");
        if(!matcher.match(expression)) {
            return null;
        }
        var number = Std.parseInt(matcher.matched(1));
        if (number == null) {
            if(mod == EXPLODE || mod == PENETRATE) {
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
        stored_dice = [for (i in 0...number) manager.getDie(sides, explode, penetrate)];
        for (die in stored_dice) {
            die.roll();
        }
        rolled_dice = stored_dice.copy();
        if(keep_highest_number != null) {
            keep_highest(keep_highest_number);
        }
        if(keep_lowest_number != null) {
            keep_lowest(keep_lowest_number);
        }
        return this;
    }

    /**
        Get an array of dice rolled as part of this roll.
    **/
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

    /**
        Returns the total sum of the die roll
    **/
    public var total(get, never) : Int;
    function get_total() : Int {
        var total = 0;
        for (die in dice) {
            total += die.result;
        }
        return total;
    };

    /**
        Keep the highest n dice in the roll (Retaining the order)
    **/
    function keep_highest(n:Int) : SimpleRoll {
        // Sort lowest to highest
        var sorted = dice.copy();
        sorted.sort((a,b) -> {
            a.result - b.result;
        });
        // Remove the lowest values down to the required kept n
        for (i in 0...(number-n)) {
            dice.remove(sorted[i]);
        }
        return this;
    }


    /**
        Keep the lowest n dice in the roll (Retaining the order)
    **/
    function keep_lowest(n:Int) : SimpleRoll {
        // Sort highest to lowest
        var sorted = dice.copy();
        sorted.sort((a,b) -> {
            b.result - a.result;
        });
        // Remove the highest values down to the required kept n
        for (i in 0...(number-n)) {
            dice.remove(sorted[i]);
        }
        return this;
    }

    /**
        Shuffles the dice using randomness generator provided to the manager. (So e.g. if it is seedy it will be re-producible)
    **/
    public function shuffle() : SimpleRoll {
        var shuffled : Array<Die> = [];
        while(dice.length > 0) {
            var n = manager.generator.rollPositiveInt(dice.length) - 1;
            var selected_die = dice[n];
            shuffled.push(selected_die);
            dice.remove(selected_die);
        }
        stored_dice = shuffled;
        return this;
    }
}