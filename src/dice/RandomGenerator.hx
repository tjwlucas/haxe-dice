package dice;
using Math;

class RandomGenerator {
    public function new() {}

    function random() {
        return Math.random();
    }

    public function rollPositiveInt(n:Int) : Int {
        return (random() * n).ceil();
    }
}