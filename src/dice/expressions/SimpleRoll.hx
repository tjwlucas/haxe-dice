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
    
    public var rolled_dice(get, never) : Array<Die>;
    function get_rolled_dice() {
        if(stored_dice != null) {
            return returnDice(true);
        }
        else {
            roll();
            return returnDice(true);
        }
    }
    
    /**
        Get an array of dice rolled as part of this roll.
    **/
    public var dice(get, never) : Array<Die>;
    function get_dice() : Array<Die> {
        if(stored_dice != null) {
            return returnDice();
        }
        else {
            roll();
            return returnDice();
        }
    };
    
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
            explode = getModifierValue(EXPLODE);
            penetrate = getModifier(EXPLODE) == '!!';

            switch(getModifier(KEEP)) {
                case 'k'|'h': keep_highest_number = getModifierValue(KEEP);
                case 'l': keep_lowest_number = getModifierValue(KEEP);
            }

            if(keep_highest_number != null) {
                if(keep_highest_number <= 0 || keep_highest_number > number) {
                    throw new dice.errors.InvalidExpression('Number of dice to keep must be between 1 and $number. ($keep_highest_number given)');
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
    function getModifierValue(mod: Modifier) : Null<Int> {
        var matcher = new EReg(Util.constructMatcher(mod), "i");
        if(!matcher.match(expression)) {
            return null;
        }
        var number = Std.parseInt(matcher.matched(2));
        if (number == null) {
            if(mod == EXPLODE) {
                number = sides;
            } else {
                number = 1;
            }
        }
        return number;
    }

    function getModifier(mod: Modifier) : Null<String> {
        var matcher = new EReg(Util.constructMatcher(mod), "i");
        if(!matcher.match(expression)) {
            return null;
        }
        var mod = matcher.matched(1);
        return mod;
    }

    /**
        Will (re-)roll all dice attached to this 'roll' object
    **/
    public function roll() : SimpleRoll {
        stored_dice = [for (i in 0...number) manager.getDie(sides, explode, penetrate)];
        for (die in stored_dice) {
            die.roll();
        }
        if(keep_highest_number != null) {
            keep_highest(keep_highest_number);
        }
        if(keep_lowest_number != null) {
            keep_lowest(keep_lowest_number);
        }
        return this;
    }


    function returnDice(?includeDropped = false) {
        return [for(die in stored_dice) if(!die.dropped || includeDropped) die];
    }

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
            sorted[i].drop();
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
            sorted[i].drop();
        }
        return this;
    }

    /**
        Shuffles the dice using randomness generator provided to the manager. (So e.g. if it is seedy it will be re-producible)
    **/
    public function shuffle() : SimpleRoll {
        var shuffled : Array<Die> = [];
        while(stored_dice.length > 0) {
            var n = manager.generator.rollPositiveInt(stored_dice.length) - 1;
            var selected_die = stored_dice[n];
            shuffled.push(selected_die);
            stored_dice.remove(selected_die);
        }
        stored_dice = shuffled;
        return this;
    }

    /**
        Returns string representation of the roll. Each 'die' separated by a comma.

        e.g. `"3"`, `"2, 6, 5"`, `"2, 6+2, 1"`
    **/
    public function toString() {
        return Std.string(rolled_dice.join(', '));
    }

    #if python
    @:keep @ignoreCoverage public function __str__() toString();
    #end
}