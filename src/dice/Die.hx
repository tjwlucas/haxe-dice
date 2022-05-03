package dice;

import dice.errors.InvalidConstructor;

/**
    Class to represent one 'die', after factoring in modifiers such as exploding dice, so it may still ultimately represent multiple physical dice 
**/
class Die {
    /**
        Number of sides on the Die object
    **/
    public var sides : Int;
    var generator : RandomGenerator;

    var explode : Null<Int>;
    var penetrate : Bool;

    /**
        List of raw dice rolled for this 'die' (i.e. If the die 'explodes', extra dice will be added on to this result)
    **/
    public var dice : Array<RawDie> = [];

    /**
        Flag to determine if this die has been dropped from the over all result.
        (e.g. In the case of a `2d6k1`, the lowest of the 2 rolled dice will be marked as 'dropped,
        and excluded from the total)
    **/
    public var dropped : Bool = false;

    public function new(sides: Int, generator : RandomGenerator, ?explode : Int, ?penetrate:Bool) {
        this.sides = sides;
        this.generator = generator;
        if (explode != null) {
            if (explode <= 1 || explode > sides) {
                throw new InvalidConstructor('Explode threshold must be between 2 and $sides');
            }
        }
        this.explode = explode;
        this.penetrate = penetrate;
    }

    /**
        The total result of the individual die roll (including exploded result)
    **/
    public var result(get, never) : Int;
    function get_result() : Int {
        if(dice.length == 0) {
            roll();
        }
        var total = 0;
        for (die in dice) {
            total += die.result;
        }
        if(penetrate) {
            total -= (dice.length-1);
        }
        return total;
    };

    /**
        This generates a new result and stores it on the object. Returns itself.
    **/
    public function roll() : Die {
        dice = [];
        var current_die = new RawDie(sides, generator);
        current_die.roll();
        this.dice.push(current_die);
        if(explode != null) {
            while (current_die.result >= explode) {
                current_die = new RawDie(sides, generator);
                current_die.roll();
                this.dice.push(current_die);
            }
        }
        return this;
    }

    /**
        Do not count this die result in the total for the parent expression 
    **/
    public function drop() {
        dropped = true;
    }

    /**
        Returns string of result (if exploded, returns expression joined with '+')

        e.g. `"4"`, `"6"`, `"6+6+2"`
    **/
    public function toString() {
        return Std.string(dice.join('+'));
    }

    #if python
    @:keep @ignoreCoverage public function __str__() toString();
    #end
}