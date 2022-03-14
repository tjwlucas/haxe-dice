package dice;

import dice.expressions.SimpleRoll;

/**
    `RollManager` manages all the libary functionality, providing access to an expression parser and evaluator, 
    as well as general die rolling functionality
**/
class RollManager {
    public var generator : RandomGenerator;

    /**
        @param generator Optionally pass in custom `RandomGenerator` (For overriding the RNG). 
        In almost all cases, you won't need/want to do this.
    **/
    public function new(?generator : RandomGenerator) {
        this.generator = (generator != null) ? generator : new RandomGenerator();
    }

    public function getRawDie(sides:Int) : RawDie {
        return new RawDie(sides, generator);
    }

    public function getSimpleRoll() {
        return new SimpleRoll(this);
    }
}