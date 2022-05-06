package tests.mock;

import utest.Assert;
import dice.RandomGenerator;

/**
	Mock class to facilitate testing functions, without randomness. 
**/
class RandomGeneratorMock extends RandomGenerator {
	/**
		Holds a list of results that return successively for each call to rollPositiveInt
	**/
    public var mockResults : Map<Int, Array<Int>> = [];

	/**
		Holds a list of results that return successively for each call to random (i.e. In the interval `[0, 1)`)
	**/
    public var mockRawResults : Array<Float> = [];
    var useRaw : Bool;

    static inline final NOT_ENOUGH_MOCKS : String = "Not enough mock results provided";

	/**
		Mock function to return next mock value for given int. 
		(If `useRaw` was set, uses the built in `rollPositiveInt` method with the `mockRawResults` list,
		otherwise, reads result from provided map)
	**/
    override public function rollPositiveInt(n:Int) : Int {
        if (useRaw) {
            return super.rollPositiveInt(n);
        }
        try {
            var resultList = mockResults[n];
            if (resultList.length == 0) {
                throw new NoMockResult(NOT_ENOUGH_MOCKS);
            }
            var nextResult = resultList[0];
            mockResults[n] = resultList.slice(1);
            return nextResult;
        } catch (e) {
            throw new NoMockResult(NOT_ENOUGH_MOCKS);
        }
    }

    override function random():Float {
        if (mockRawResults.length == 0) {
            throw new NoMockResult(NOT_ENOUGH_MOCKS);
        }
        var nextResult = mockRawResults[0];
        mockRawResults = mockRawResults.slice(1);
        return nextResult;
    }

	/**
		Throws an assertion error if there are any unused values on any of the moc result lists
	**/
    public function shouldBeDoneAll(?pos:haxe.PosInfos) : Void {
        for (key => value in mockResults) {
            shouldBeDone(key, pos);
        }
        shouldBeDoneRaw(pos);
    }

	/**
		Throws an assertion error if there are any unused values still on `mockRawResults`
	**/
    public inline function shouldBeDoneRaw(?pos:haxe.PosInfos) : Void {
        Assert.equals(0, mockRawResults.length, '(Failure) There are unused mock raw results: ${mockRawResults}', pos);
    }

	/**
		Throws an assertion error if there are any unused values still on `mockResults[n]`

		@param n Integer to check for unused mock values
	**/
    public inline function shouldBeDone(n:Int, ?pos:haxe.PosInfos) : Void {
        var value = mockResults[n];
        Assert.equals(0, value.length, '(Failure) There are unused mock results for ${n}: ${value}', pos);
    }
}
