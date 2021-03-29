package dice;

class RollManager {
    public var generator : RandomGenerator;

    public function new(?generator : RandomGenerator) {
        this.generator = (generator != null) ? generator : new RandomGenerator();
    }

    public function getRawDie(n:Int) : RawDie {
        return new RawDie(n, generator);
    }
}