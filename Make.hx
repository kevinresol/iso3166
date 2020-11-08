package;

import haxe.macro.Context;
import haxe.io.Path;

using StringTools;
using sys.io.File;
using haxe.Json;

class Make {
	static function main() {
		final raw = 'data.json'.getContent()
			.replace('"Alpha-2 code"', '"Alpha2"')
			.replace('"Alpha-3 code"', '"Alpha3"')
			.replace('"Numeric code"', '"Numeric"')
			.replace('"Latitude (average)"', '"Latitude"')
			.replace('"Longitude (average)"', '"Longitude"');
		
		final data:Array<Data> = raw.parse();
		
		final alpha2 = macro class Alpha2 {}
		final alpha3 = macro class Alpha3 {}
		final numeric = macro class Numeric {}
		
		alpha2.kind = alpha3.kind = TDAbstract(macro:String, [], [macro:String]);
		numeric.kind = TDAbstract(macro:Int, [], [macro:Int]);
		alpha2.meta = alpha3.meta = numeric.meta = [{name: ':enum', pos: null}];
		final pack = alpha2.pack = alpha3.pack = numeric.pack = ['iso3166', 'part1'];
		
		final unique2 = [];
		final unique3 = [];
		final uniqueN = [];
		for(entry in data) {
			
			if(!unique2.contains(entry.Alpha2)) {
				unique2.push(entry.Alpha2);
				alpha2.fields.push({
					name: entry.Alpha2,
					pos: null,
					kind: FVar(null, {expr: EConst(CString(entry.Alpha2)), pos: null}),
				});
			}
			if(!unique3.contains(entry.Alpha3)) {
				unique3.push(entry.Alpha3);
				alpha3.fields.push({
					name: entry.Alpha3,
					pos: null,
					kind: FVar(null, {expr: EConst(CString(entry.Alpha3)), pos: null}),
				});
			}
			if(!uniqueN.contains(entry.Numeric)) {
				uniqueN.push(entry.Numeric);
				numeric.fields.push({
					name: entry.Alpha3,
					pos: null,
					kind: FVar(null, {expr: EConst(CInt('${entry.Numeric}')), pos: null}),
				});
			}
		}
		
		final printer = new haxe.macro.Printer();
		final folder = Path.join(['src'].concat(pack));
		Path.join([folder, alpha2.name + '.hx']).saveContent(printer.printTypeDefinition(alpha2));
		Path.join([folder, alpha3.name + '.hx']).saveContent(printer.printTypeDefinition(alpha3));
		Path.join([folder, numeric.name + '.hx']).saveContent(printer.printTypeDefinition(numeric));
		
	}
}

typedef Data = {
	Country:String,
	Alpha2:String,
	Alpha3:String,
	Numeric:Int,
	Longitude:Float,
	Latitude:Float,
}