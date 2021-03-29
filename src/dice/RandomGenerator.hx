package dice;
using Math;

/**
    `RandomGenerator` is where all (pseudo) random number generation takes place.

    To replace the RNG logic, e.g. to mock results or use a seedy RNG, this is the class to extend, and replace the `RandomGenerator.rollPositiveInt` method.
**/
class RandomGenerator {
    public function new() {}

    function random() : Float {
        return Math.random();
    }

    /**
        Returns a generated random integer between `1` and `n` (inclusive).
        
        e.g. `rollPositiveInt(6)` will return a result equivalent to rolling a 6-sided die.
    **/
    public function rollPositiveInt(n:Int) : Int {
        return (random() * n).floor() + 1;
    }
}