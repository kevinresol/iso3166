package;

import iso3166.part1.*;

class Main {
	static function main() {
		var alpha2:Alpha2 = HK;
		var alpha3:Alpha3 = HKG;
		var numeric:Numeric = HKG;
		
		trace(alpha2);
		trace(alpha3);
		trace(numeric);
		trace((alpha2:Numeric));
		trace((alpha3:Numeric));
		trace((alpha3:Alpha2));
		trace((numeric:Alpha2));
		trace((alpha2:Alpha3));
		trace((numeric:Alpha3));
	}
}