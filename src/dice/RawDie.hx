package dice;

using Math;

class RawDie {
    var sides : Int;
    var generator : RandomGenerator;

    public function new(sides:Int, generator : RandomGenerator) {
        this.sides = sides;
        this.generator = generator;
    }

    var stored_result : Int;

    public var result(get, null) : Int;
    public function get_result() : Int {
        if(stored_result != null) return stored_result;
        else return roll();
    };

    public function roll() {
        stored_result = generator.rollPositiveInt(sides);
        return stored_result;
    }
}