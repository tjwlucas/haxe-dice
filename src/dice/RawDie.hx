package dice;

import dice.errors.InvalidConstructor;
using Math;

/**
    Represent the most basic unit of a die roll
    (i.e. One physical die)

    Will not generally be instantiated directly, instead use `RollManager.getRawDie()`

    @see `RollManager.getRawDie()`
**/
class RawDie {
    /**
        The number of sides on the die
    **/
    public var sides : Int;
    var generator : RandomGenerator;

    @:dox(hide)
    public function new(sides:Int, generator : RandomGenerator) {
        var sides_int : Int;
        try {
            if(sides <= 0) {
                throw new InvalidConstructor("Non-positive number given");
            }
            #if php
                // On other targets, the cast will fail anyway
                if(sides.floor() != sides.ceil()) {
                    throw new InvalidConstructor("Non-integer given");
                }
            #end
            sides_int = cast(sides, Int);
        } catch (e) {
            throw new InvalidConstructor("Must have positive integer number of sides");
        }
        this.sides = sides_int;
        this.generator = generator;
    }

    var stored_result : Null<Int>;

    /**
        Gets the stored result of the die roll.

        If it has not yet been rolled, it will call `RawDie.roll()`, then return it.
    **/
    public var result(get, never) : Int;
    function get_result() : Int {
        if(stored_result != null) return stored_result;
        else return roll();
    };

    /**
        Rolls the die, storing the result on the die object, as well as returning it
    **/
    public function roll() : Int {
        var ans = generator.rollPositiveInt(sides);
        stored_result = ans;
        return ans;
    }

    public function toString() {
        return Std.string(result);
    }
}