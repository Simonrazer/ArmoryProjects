package arm;
import io.colyseus.Client;
import io.colyseus.serializer.schema.Schema;
import io.colyseus.Room;
import iron.object.Object;
import iron.system.Input;
import iron.math.Vec4;
import armory.system.Event;
import iron.math.Mat4;
import iron.math.Quat;
import armory.trait.physics.RigidBody;
import iron.Scene;
import armory.trait.internal.CanvasScript;

class PlayerSync extends iron.Trait {

	//   wss://upl0ad.herokuapp.com:443  -> heroku
	//	 ws://localhost:2567 -> local
	//   wss://indigo-lint-2pqmf9036.glitch.me:443 -> glitch
	var client = new Client('wss://indigo-lint-2pqmf9036.glitch.me:443'); 
	var K:String = "nix";
	var go = true;
	var r:Dynamic;
	var POS = new Vec4();
	var SPEED = new Vec4();
	var i:Int = 0;
	var t = iron.system.Time.time();
	var playerObj:Dynamic;
	var mVec = new Map<String, Vec4>();
	var otherPlayers:Dynamic;
	var playerCount: Int = 0;
	var listener: TEvent = null;
	var chatMessages: Array<String> = [];
	var moX:Int;
	var moY:Int;
	var l:Bool;

	public function new() {
		super();
		
		var tii = kha.Scheduler.realTime();
		untyped __js__("

        khanvas.requestPointerLock = khanvas.requestPointerLock ||
                                    khanvas.mozRequestPointerLock;

        document.exitPointerLock = document.exitPointerLock ||
                                document.mozExitPointerLock;

        khanvas.onclick = function() {
        khanvas.requestPointerLock();
        };
		");
		
		js.Browser.document.addEventListener("mousemove",mm);

		listener = Event.add("Chat", chat);
		otherPlayers = new Array();
		playerObj = iron.Scene.active.getChild("PlayerBody");
		var yourTimer:haxe.Timer = new haxe.Timer(20);
		yourTimer.run = function():Void{
			POS = playerObj.transform.world.getLoc();
			if (playerObj.properties != null){
				SPEED = playerObj.properties.get("S");
				if (K != "nix"){
					r.send({x: POS.x});
					r.send({y: POS.y});
					r.send({z: POS.z});
					r.send({mx: SPEED.x});
					r.send({my: SPEED.y});
					r.send({mz: SPEED.z});
				}
				//else trace("connecting");
			}
			else trace ("initializing");
		};

		var roomID = Reflect.field(iron.system.Storage.data, "roomid");
		trace(roomID);

		client.joinOrCreate("my_room", [], State, function(err, room) {
			trace("trying");
			if (err != null) {
				trace("JOIN ERROR: " + err);
				return;
			}		
			trace("Joined")	;
			r = room;

			room.state.players.onChange = function(player, key) {
				//trace(iron.system.Time.time() - t);
				t = iron.system.Time.time();
				//Move other player
				if (key != K){
					var o = iron.Scene.active.getChild(key);
					var vec = new Vec4();
					vec.x = player.x; vec.y = player.y; vec.z = player.z;
					o.transform.loc.setFrom(vec);
					o.transform.buildMatrix();
					#if arm_physics
					var rigidBody = o.getTrait(RigidBody);
					if (rigidBody != null) rigidBody.syncTransform();
					#end
					mVec[key] = new Vec4(player.mx, player.my, player.mz, 0);
				}
				if (player.msg != null){
					chatMessages.push(key + ": " + player.msg);
					trace(chatMessages[0]);
					#if arm_ui
					var canvas: CanvasScript = null;

					if (canvas == null) canvas = Scene.active.getTrait(CanvasScript);
					if (canvas == null || !canvas.ready) canvas = null;
									
					if (canvas != null){
						if (chatMessages[Std.int(chatMessages.length-4)] != null){
							canvas.getElement("C4").text = chatMessages[Std.int(chatMessages.length-4)];
						}
						if (chatMessages[Std.int(chatMessages.length-3)] != null){
							canvas.getElement("C3").text = chatMessages[Std.int(chatMessages.length-3)];
						}
						if (chatMessages[Std.int(chatMessages.length-2)] != null){
							canvas.getElement("C2").text = chatMessages[Std.int(chatMessages.length-2)];
						}
						if (chatMessages[Std.int(chatMessages.length-1)] != null){
							canvas.getElement("C1").text = chatMessages[Std.int(chatMessages.length-1)];
						}
					}										
					#end
				}
			}

			room.state.players.onRemove = function(player, key){
				iron.Scene.active.getChild(key).remove();
				var pos = otherPlayers.indexOf(key);
				for (i in pos...playerCount){
					otherPlayers[i] = otherPlayers[i+1];
				}
				playerCount--;
			}
			
			room.state.players.onAdd = function(player, key){
				if(go){
					K = key;	//Find own Key			
					haxe.Timer.delay(stop, 100);					
				}

				mVec[key] = new Vec4(0,0,0,0);
				iron.Scene.active.spawnObject("OTHER", null, function(o: Object) {
					var matrix: Mat4 = Mat4.identity();
					var q = new Quat();
					var s = new Vec4(); s.x = 1; s.y = 1; s.z = 1;
					var p = new Vec4(); p.x = 0; p.y = 0; p.z = -101;
					q.fromEuler(0,0,0);
					matrix.compose(p, q, s);
					var object = o;
					object.transform.setMatrix(matrix);
					object.transform.buildMatrix();
					var rigidBody = object.getTrait(RigidBody);
					if (rigidBody != null) rigidBody.syncTransform();

					object.visible = true;
					object.name = key;
					otherPlayers[playerCount] = key;
				}, false);

				playerCount++;
			}			
		});
	
		
		notifyOnUpdate(function() {
			for (i in 0...playerCount){
				var oP = iron.Scene.active.getChild(otherPlayers[i]);
				oP.transform.loc.add(mVec[oP.name]);
				oP.transform.buildMatrix();
				var rigidBody = oP.getTrait(RigidBody);
				if (rigidBody != null) rigidBody.syncTransform();
			}

		
			var playerObj = iron.Scene.active.getChild("PlayerBody");
			if (playerObj.properties == null) playerObj.properties = new Map();
			playerObj.properties.set("MX", moX);
			playerObj.properties.set("MY", moY);
			playerObj.properties.set("L", l);
			l = false;
		});	
		
		// notifyOnRemove(function() {
		// });
	}

	function mm(e){
		moX = e.movementX;
		moY = e.movementY;
		l = true;
	}
	
	function stop(){
		go = false;
	}

	function chat(){
		var canvas: CanvasScript = null;
		trace("kkk");
		if (canvas == null) canvas = Scene.active.getTrait(CanvasScript);
		if (canvas == null || !canvas.ready) canvas = null;

		if (canvas != null){
			var input = canvas.getHandle("TextInput").text;
			r.send({msg: input});
		}
	}
}

