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

    @:allow(dice.Die, dice.RollManager)
    function new(sides:Int, generator : RandomGenerator) {
        var sidesInt : Int;
        try {
            if (sides <= 0) {
                throw new InvalidConstructor("Non-positive number given");
            }
            #if php
                // On other targets, the cast will fail anyway
                if (sides.floor() != sides.ceil()) {
                    throw new InvalidConstructor("Non-integer given");
                }
            #end
            sidesInt = cast(sides, Int);
        } catch (e) {
            throw new InvalidConstructor("Must have positive integer number of sides");
        }
        this.sides = sidesInt;
        this.generator = generator;
    }

    var storedResult : Null<Int>;

    /**
        Gets the stored result of the die roll.

        If it has not yet been rolled, it will call `RawDie.roll()`, then return it.
    **/
    public var result(get, never) : Int;
    function get_result() : Int {
        if (storedResult != null) return storedResult;
        else return roll();
    };

    /**
        Rolls the die, storing the result on the die object, as well as returning it
    **/
    public function roll() : Int {
        var ans = generator.rollPositiveInt(sides);
        storedResult = ans;
        return ans;
    }

    /**
        Returns result as a string
    **/
    public function toString() : String {
        return Std.string(result);
    }

    #if python
        @SuppressWarnings("checkstyle:CodeSimilarity") @:keep @ignoreCoverage public function __str__() toString();
    #end
}