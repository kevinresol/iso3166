package;

import haxe.macro.Expr;
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
		
		
		
		final cases23:Array<Case> = [];
		final cases2N:Array<Case> = [];
		final cases32:Array<Case> = [];
		final cases3N:Array<Case> = [];
		final casesN2:Array<Case> = [];
		final casesN3:Array<Case> = [];
		
		final alpha2 = macro class Alpha2 {
			@:to public function toAlpha3():Alpha3 return ${{expr: ESwitch(macro (cast this:Alpha2), cases23, null), pos: null}}
			@:to public function toNumeric():Numeric return ${{expr: ESwitch(macro (cast this:Alpha2), cases2N, null), pos: null}}
		}
		final alpha3 = macro class Alpha3 {
			@:to public function toAlpha2():Alpha2 return ${{expr: ESwitch(macro (cast this:Alpha3), cases32, null), pos: null}}
			@:to public function toNumeric():Numeric return ${{expr: ESwitch(macro (cast this:Alpha3), cases3N, null), pos: null}}
		}
		final numeric = macro class Numeric {
			@:to public function toAlpha2():Alpha2 return ${{expr: ESwitch(macro (cast this:Numeric), casesN2, null), pos: null}}
			@:to public function toAlpha3():Alpha3 return ${{expr: ESwitch(macro (cast this:Numeric), casesN3, null), pos: null}}
		}
		
		alpha2.kind = alpha3.kind = TDAbstract(macro:String, [], [macro:String]);
		numeric.kind = TDAbstract(macro:Int, [], [macro:Int]);
		alpha2.meta = alpha3.meta = numeric.meta = [{name: ':enum', pos: null}];
		final pack = alpha2.pack = alpha3.pack = numeric.pack = ['iso3166', 'part1'];
		
		final unique2 = [];
		final unique3 = [];
		final uniqueN = [];
		
		for(entry in data) {
			final a2 = entry.Alpha2;
			final a3 = entry.Alpha3;
			final n = entry.Numeric;
			
			if(!unique2.contains(a2)) {
				unique2.push(a2);
				alpha2.fields.push({
					name: a2,
					pos: null,
					kind: FVar(null, {expr: EConst(CString(a2)), pos: null}),
				});
				cases23.push({
					values: [macro $i{a2}],
					expr: macro Alpha3.$a3,
				});
				cases2N.push({
					values: [macro $i{a2}],
					expr: macro Numeric.$a3,
				});
			}
			if(!unique3.contains(a3)) {
				unique3.push(a3);
				alpha3.fields.push({
					name: a3,
					pos: null,
					kind: FVar(null, {expr: EConst(CString(a3)), pos: null}),
				});
				cases32.push({
					values: [macro $i{a3}],
					expr: macro Alpha2.$a2,
				});
				cases3N.push({
					values: [macro $i{a3}],
					expr: macro Numeric.$a3,
				});
			}
			if(!uniqueN.contains(n)) {
				uniqueN.push(n);
				numeric.fields.push({
					name: a3,
					pos: null,
					kind: FVar(null, {expr: EConst(CInt('$n')), pos: null}),
				});
				casesN2.push({
					values: [macro $i{a3}],
					expr: macro Alpha2.$a2,
				});
				casesN3.push({
					values: [macro $i{a3}],
					expr: macro Alpha3.$a3,
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