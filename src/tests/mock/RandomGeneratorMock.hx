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

	public function shouldBeDoneAll(fail : Bool = true, ?pos:haxe.PosInfos) {
		for(key => value in mock_results) {
			shouldBeDone(key, fail, pos);
		}	
		shouldBeDoneRaw(fail, pos);
	}

	public function shouldBeDoneRaw(fail : Bool = true, ?pos:haxe.PosInfos) {
		if(mock_raw_results.length > 0) {
			if(fail) {
				Assert.fail('(Failure) There are unused mock raw results: ${mock_raw_results}', pos);
			} else {
				Assert.warn('line: ${pos.lineNumber}, (Warning) There are unused mock raw results: ${mock_raw_results}');
			}
		}
	}

	public function shouldBeDone(n:Int, fail : Bool = true, ?pos:haxe.PosInfos) {
		var value = mock_results[n];
		if(value.length > 0) {
			if(fail) {
				Assert.fail('(Failure) There are unused mock results for ${n}: ${value}', pos);
			} else {
				Assert.warn('line: ${pos.lineNumber}, (Warning) There are unused mock results for ${n}: ${value}');
			}
		}
	}
}
