package tests.cases;

import dice.RandomGenerator;
import utest.Assert;
import dice.RollManager;
import utest.Test;

class RollManagerTest extends Test {
    function specConstructor() {
        var manager = new RollManager();
        Assert.isOfType(manager.generator, RandomGenerator);

        var generator = new RandomGenerator();
        var manager = new RollManager(generator);
        Assert.isOfType(manager.generator, RandomGenerator);
        manager.generator == generator;
    }
}
