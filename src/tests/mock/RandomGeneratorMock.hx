package tests.mock;
import haxe.Exception;
import dice.RandomGenerator;

class RandomGeneratorMock extends RandomGenerator {
	public var mock_results : Map<Int, Array<Int>> = [];
	override public function rollPositiveInt(n:Int) : Int {
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
}
