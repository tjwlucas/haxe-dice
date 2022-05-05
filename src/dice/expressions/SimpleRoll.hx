package dice.expressions;

import dice.util.Util;
import dice.enums.Modifier;
import dice.macros.RollParsingMacros;
import dice.errors.InvalidExpression;

/**
    Represents a simple roll, represented by a single die statement

    e.g. `d6`, `2d20`, `3d8k`, `2d6!` etc.

    Every expression *must* include at its core a base roll matching `d[0-9]+` (e.g. `d6`). 
    If there is a number in front (e.g. `3d20`), the die will be rolled that many times.

    There a currently 2 main classes of modifier permitted afterwards:

    - Keep
        Keep highest (`k`/`h`) or lowest (`l`). By default will kep one result, but if followed by a number, will keep that many.

        e.g. `2d20k` will roll 2 `d20` and keep the highest. `3d6h2` will roll 3 `d6` and keep the highest 2. 
        `3d6l` will roll 3d6 and keep the lowest one.
    
    - Exploding/Penetrating Dice
        `!` will, for each die rolled, if the provided threshold (default: the max on the die) is reached, 
        reroll and add the result, continuing if that meats the threshold, and so on. 
        If a number is provided after the `!`, that will be used as the threshold.
        If `!!` is used, instead of `!`, one will be subtracted from the result, before each addition (this is sometimes referred to as 'penetrating' dice).
**/
class SimpleRoll {
    /**
        Number of sides on the die used in this roll
    **/
    public var sides : Int;
    /**
        Base number of dice represented on this roll
    **/
    public var number : Int;

    var expression : String;

    var manager : Null<RollManager>;

    var storedDice : Null<Array<Die>>;
    var explode : Null<Int>;
    var penetrate : Bool;
    var keepHighestNumber : Null<Int>;
    var keepLowestNumber : Null<Int>;
    
    /**
        All dice rolled for this expression (before any are dropped)
    **/
    public var rolledDice(get, never) : Array<Die>;
    function get_rolledDice() {
        if(storedDice != null) {
            return returnDice(true);
        } else {
            roll();
            return returnDice(true);
        }
    }
    
    /**
        Get an array of dice rolled as part of this roll (After any are dropped).
    **/
    public var dice(get, never) : Array<Die>;
    function get_dice() : Array<Die> {
        if(storedDice != null) {
            return returnDice();
        } else {
            roll();
            return returnDice();
        }
    };
    
    /**
        The general regex that will match a valid die expression
    **/
    static inline final MATCHING_STRING = RollParsingMacros.buildSimpleRollExpression();

    public function new(manager: RollManager, ?expression: String) {
        this.manager = manager;
        if(expression != null) {
            this.parse(expression);
        }
    }

    /**
        @param newExpression A 'simple' die-notation style expression (a single roll). Such as `2d6`, `3d4`, `d20`
        @throws dice.errors.InvalidExpression When passed an invalid expression
    **/
    public function parse(newExpression : String) : SimpleRoll {
        var oldExpression = this.expression;
        this.expression = newExpression;
        try {
            var basic = parseCoreExpression(newExpression);
            number = basic.number != null ? basic.number : 1;
            sides = basic.sides;
            explode = getModifierValue(EXPLODE);
            penetrate = getModifier(EXPLODE) == "!!";

            switch(getModifier(KEEP)) {
                case "k"|"h": keepHighestNumber = getModifierValue(KEEP);
                case "l": keepLowestNumber = getModifierValue(KEEP);
            }

            verifyKeepNumber(keepHighestNumber);
            verifyKeepNumber(keepLowestNumber);

            return this;
        } catch (e) {
            this.expression = oldExpression;
            throw new InvalidExpression('$newExpression is not a valid core die expression');
        }
    }

    inline function verifyKeepNumber(keepNumber : Null<Int>) {
        if(keepNumber != null) {
            if(keepNumber <= 0 || keepNumber > number) {                
                throw new InvalidExpression('Number of dice to keep must be between 1 and $number. ($keepNumber given)');
            }
        }
    }

    /**
        Validates the provided expression and extracts the initial basic info (number of dice and number of sides)
    **/
    function parseCoreExpression(passedExpression : String) {
        var matcher = new EReg(MATCHING_STRING, "i");
        if (matcher.match(passedExpression)) {
            var numberInExpression = Std.parseInt(matcher.matched(1));
            var sidesInExpression = Std.parseInt(matcher.matched(2));
            return {
                number: numberInExpression,
                sides: sidesInExpression
            };
        } else {
            throw new dice.errors.InvalidExpression('$passedExpression is not a valid core die expression');
        };
    }

    /**
        Get modifier value for given modifier. If requested modifier is present, but with no number, defaults to 1.
        Returns null if modifier not present.
        @param mod Parameter key. e.g. The modifier "k" on the expression "4d6k2" would return 2.
    
    **/
    function getModifierValue(mod: Modifier) : Null<Int> {
        var matcher = new EReg(Util.constructMatcher(mod), "i");
        if(matcher.match(expression)) {            
            var numberParameter = Std.parseInt(matcher.matched(2));
            if (numberParameter == null) {
                if(mod == EXPLODE) {
                    numberParameter = sides;
                } else {
                    numberParameter = 1;
                }
            }
            return numberParameter;
        } else {
            return null;
        }
    }

    function getModifier(mod: Modifier) : Null<String> {
        var matcher = new EReg(Util.constructMatcher(mod), "i");
        if(matcher.match(expression)) {
            var mod = matcher.matched(1);
            return mod;
        } else {
            return null;
        }
    }

    /**
        Will (re-)roll all dice attached to this 'roll' object
    **/
    public function roll() : SimpleRoll {
        storedDice = [for (i in 0...number) manager.getDie(sides, explode, penetrate)];
        for (die in storedDice) {
            die.roll();
        }
        if(keepHighestNumber != null) {
            keepHighest(keepHighestNumber);
        }
        if(keepLowestNumber != null) {
            keepLowest(keepLowestNumber);
        }
        return this;
    }


    function returnDice(?includeDropped = false) {
        return [for(die in storedDice) if(!die.dropped || includeDropped) die];
    }

    /**
        Returns the total sum of the die roll
    **/
    public var total(get, never) : Int;
    function get_total() : Int {
        var runningTotal = 0;
        for (die in dice) runningTotal += die.result;
        return runningTotal;
    };
    
    /**
        Keep the highest n dice in the roll (Retaining the order)
    **/
    function keepHighest(n:Int) : SimpleRoll {
        return keepFirstSorted(n, (a,b) -> a.result - b.result);
    }


    /**
        Keep the lowest n dice in the roll (Retaining the order)
    **/
    function keepLowest(n:Int) : SimpleRoll {
        return keepFirstSorted(n, (a,b) -> b.result - a.result);
    }

    function keepFirstSorted(n:Int, sorter:(Die, Die)->Int) {
        var sorted = dice.copy();
        sorted.sort(sorter);
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
        while(storedDice.length > 0) {
            var n = manager.generator.rollPositiveInt(storedDice.length) - 1;
            var selectedDie = storedDice[n];
            shuffled.push(selectedDie);
            storedDice.remove(selectedDie);
        }
        storedDice = shuffled;
        return this;
    }

    /**
        Returns string representation of the roll. Each 'die' separated by a comma.

        e.g. `"3"`, `"2, 6, 5"`, `"2, 6+2, 1"`
    **/
    public function toString() {
        return Std.string(rolledDice.join(", "));
    }

    #if python
    @SuppressWarnings("checkstyle:CodeSimilarity") @:keep @ignoreCoverage public function __str__() toString();
    #end
}