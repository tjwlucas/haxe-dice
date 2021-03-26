package tests.mock;
import utest.Assert;
import haxe.Exception;
import dice.RandomGenerator;

class RandomGeneratorMock extends RandomGenerator {
	public var mock_results : Map<Int, Array<Int>> = [];
	public var mock_raw_results : Array<Float> = [];
	public var use_raw : Bool;
	override public function rollPositiveInt(n:Int) : Int {
		if(use_raw) {
			return super.rollPositiveInt(n);
		}
        try {
			var result_list = mock_results[n];
			if(result_list.length == 0) {
				throw new NoMockResult("Not enough mock results provided");
			}
			var next_result = result_list[0];
			mock_results[n] = result_list.slice(1);
			return next_result;
		} catch (e) {
			throw new NoMockResult("No mock results provided");
		}
    }

	override function random():Float {		
		if(mock_raw_results.length == 0) {
			throw new NoMockResult("Not enough mock results provided");
		}
		var next_result = mock_raw_results[0];
		mock_raw_results = mock_raw_results.slice(1);
		return next_result;
	}

	public function shouldBeDoneAll(?pos:haxe.PosInfos) {
		for(key => value in mock_results) {
			shouldBeDone(key, pos);
		}	
		shouldBeDoneRaw(pos);
	}

	public inline function shouldBeDoneRaw(?pos:haxe.PosInfos) {
		Assert.equals(0, mock_raw_results.length, '(Failure) There are unused mock raw results: ${mock_raw_results}', pos);
	}

	public inline function shouldBeDone(n:Int, ?pos:haxe.PosInfos) {
		var value = mock_results[n];
		Assert.equals(0, value.length, '(Failure) There are unused mock results for ${n}: ${value}', pos);
	}
}
