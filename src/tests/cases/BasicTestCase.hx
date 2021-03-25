package tests.cases;

import tests.mock.NoMockResult;
import utest.Assert;
import utest.Test;
import tests.mock.RandomGeneratorMock;

class BasicTestCase extends Test {
    var generator : RandomGeneratorMock;
    var manager : dice.RollManager;
    function setup() {
        generator = new RandomGeneratorMock();
        manager = new dice.RollManager(generator);
    }

    function specBasicDieMocking() {
        generator.mock_results[6] = [2,4,3];
        var d6 = manager.getRawDie(6);
        d6.result == 2;
        d6.roll() == 4;
        d6.result == 4;
        d6.roll() == 3;
        d6.result == 3;
        Assert.raises(() -> d6.roll(), NoMockResult);
        d6.result == 3;

        var d20 = manager.getRawDie(20);

        generator.mock_results[20] = [15, 1, 20];
        d20.result == 15;
        d20.roll() == 1;
        d20.roll() == 20;

        generator.mock_results = [
            6 => [1,2,3],
            20 => [3, 16, 20, 1]
        ];

        d6.roll() == 1;
        d6.roll() == 2;
        d20.roll() == 3;
        d20.roll() == 16;
        d20.roll() == 20;
        d6.roll() == 3;
        Assert.raises(() -> d6.roll(), NoMockResult);
        d20.roll() == 1;
        Assert.raises(() -> d20.roll(), NoMockResult);
    }
}