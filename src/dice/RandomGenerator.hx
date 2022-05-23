package dice;

import dice.enums.RandomGeneratorType;
using Math;

/**
    `RandomGenerator` is where all (pseudo) random number generation takes place. (By default, using a simple haxe `Math.random()` call)

    To replace the RNG logic, e.g. to use custom RNG algorithm, this is the class to extend, and replace the `RandomGenerator.rollPositiveInt` method.

    @see https://api.haxe.org/Math.html#random
**/
class RandomGenerator {
    var type : RandomGeneratorType;

    #if seedyrng
        var seedyRng : Null<seedyrng.Random>;
    #end

    public function new(type:RandomGeneratorType = Default) {
        this.type = type;
        switch (type) {
            #if seedyrng
                case Seedy(seed): {
                        this.seedyRng = new seedyrng.Random();
                        this.seedyRng.setStringSeed(seed);
                    }
            #end
            case Default:
        }
    }

    function random() : Float {
        return switch (type) {
            #if seedyrng
                case Seedy(_): this.seedyRng.random();
            #end
            case Default: Math.random();
        }
    }

    /**
        Returns a generated random integer between `1` and `n` (inclusive).
        
        e.g. `rollPositiveInt(6)` will return a result equivalent to rolling a 6-sided die.

        @param n Max value to be rolled
    **/
    public function rollPositiveInt(n:Int) : Int {
        return (random() * n).floor() + 1;
    }
}