// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 0.5.24
// 

package arm;
import io.colyseus.serializer.schema.Schema;

class Player extends Schema {
	@:type("number")
	public var x: Dynamic = 0;

	@:type("number")
	public var y: Dynamic = 0;

	@:type("number")
	public var z: Dynamic = 0;

	@:type("number")
	public var mx: Dynamic = 0;

	@:type("number")
	public var my: Dynamic = 0;

	@:type("number")
	public var mz: Dynamic = 0;

	@:type("string")
	public var msg: String = "";

}
