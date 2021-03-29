package dice;

/**
    `RollManager` manages all the libary functionality, proividing access to an expression parser and evaluator, 
    as well as general die rolling functionality
**/
class RollManager {
    public var generator : RandomGenerator;

    public function new(?generator : RandomGenerator) {
        this.generator = (generator != null) ? generator : new RandomGenerator();
    }

    public function getRawDie(n:Int) : RawDie {
        return new RawDie(n, generator);
    }
}