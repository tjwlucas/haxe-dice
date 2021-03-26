package tests;

import utest.Runner;

class Tests {
	public static function main() {
		var runner = new Runner();
		new NoExitReport(runner);
		runner.addCases(tests.cases);
		runner.run();
	}
}

class NoExitReport extends utest.ui.text.PrintReport {
	override function complete(result:utest.ui.common.PackageResult) {
		this.result = result;

		#if js
		js.html.Console.log(this.getResults());
		#elseif sys
		Sys.println(this.getResults());
		#end
		
		#if instrument
			instrument.coverage.Coverage.endCoverage();
		#end
		if (!result.stats.isOk) {
			#if sys
			Sys.exit(1);
			#elseif js
			js.Syntax.code('process.exit(1)');
			#end
		}
	}
}
