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

    public var dice : Array<RawDie> = [];

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
}