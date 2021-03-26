package dice;

import dice.errors.InvalidConstructor;
using Math;

class RawDie {
    var sides : Int;
    var generator : RandomGenerator;

    public function new(sides:Int, generator : RandomGenerator) {
        var sides_int : Int;
        try {
            if(sides <= 0) {
                throw "Non-positive number given";
            }
            #if php
                // On other targets, the cast will fail anyway
                if(sides.floor() != sides.ceil()) {
                    throw "Non-integer given";
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

    public var result(get, never) : Int;
    public function get_result() : Int {
        if(stored_result != null) return stored_result;
        else return roll();
    };

    public function roll() {
        var ans = generator.rollPositiveInt(sides);
        stored_result = ans;
        return ans;
    }
}