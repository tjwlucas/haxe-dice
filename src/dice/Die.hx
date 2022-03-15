package dice;

import dice.errors.InvalidConstructor;

class Die {
    public var sides : Int;
    var generator : RandomGenerator;

    var explode : Null<Int>;

    var dice : Array<RawDie> = [];

    public function new(sides: Int, generator : RandomGenerator, ?explode : Int) {
        this.sides = sides;
        this.generator = generator;
        if (explode <= 1 || explode > sides) {
            throw new InvalidConstructor('Explode threshold must be between 2 and $sides');
        }
        this.explode = explode;
    }

    public var result(get, never) : Int;
    function get_result() : Int {
        if(dice.length == 0) {
            roll();
        }
        var total = 0;
        for (die in dice) {
            total += die.result;
        }
        return total;
    };

    public function roll() : Die {
        dice = [];
        var current_die = new RawDie(sides, generator);
        current_die.roll();
        this.dice.push(current_die);
        while (current_die.result >= explode) {
            current_die = new RawDie(sides, generator);
            current_die.roll();
            this.dice.push(current_die);
        }
        return this;
    }
}