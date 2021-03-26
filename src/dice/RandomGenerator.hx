package dice;
using Math;

class RandomGenerator {
    public function new() {}

    function random() : Float {
        return Math.random();
    }

    public function rollPositiveInt(n:Int) : Int {
        return (random() * n).floor() + 1;
    }
}