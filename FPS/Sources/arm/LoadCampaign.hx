package arm;

import iron.math.Vec4;
import iron.object.Transform;
import iron.data.SceneFormat.TSceneFormat;
import zui.Canvas;
import iron.Scene;
import armory.system.Event;
import iron.object.Object;
import iron.math.Mat4;
import iron.system.Input;
import armory.trait.physics.RigidBody;
import armory.trait.internal.CanvasScript;
import kha.graphics2.Graphics;

class LoadCampaign extends iron.Trait {
	var events:TEvent = null;
	var root:Object = null;
	var entries:Array<TEvent> = null;
	var lvToLoad:String;

	public function new() {
		super();

		function lvLoad():Void {
			Scene.setActive(lvToLoad + ".json", function(o:Object) {
				root = Scene.active.addObject();
				root.name = "info_player_start";
				Scene.active.addScene("Player.json", root, function(o:Object) {
					var cam = iron.Scene.active.getCamera("Camera");
					Scene.active.getChild("startGrnd").remove();
					cam.buildProjection();
					Scene.active.camera = cam;
					var rigidBody = o.getTrait(RigidBody);
					if (rigidBody != null)
						rigidBody.syncTransform();
					entries = Event.get("playerReset");

					if (entries != null) {
						for (e in entries)
							e.onEvent();
					}
				});
			});
		}

		notifyOnInit(function() {
			trace("Loading...");
			events = Event.add("lv1load", function() {
				lvToLoad = "Lv1";
				lvLoad();
			});
			events = Event.add("lv2load", function() {
				lvToLoad = "Lv2";
				lvLoad();
			});
			events = Event.add("lv3load", function() {
				lvToLoad = "Lv3";
				lvLoad();
			});
			events = Event.add("lv4load", function() {
				lvToLoad = "Lv4";
				lvLoad();
			});
		});

		notifyOnUpdate(function() {
			var key = Input.getKeyboard();
			if (key.started("f")) {
				iron.data.Data.getSceneRaw("Player.json", function(format:TSceneFormat) {
					var obj = Scene.getRawObjectByName(format, "Mine");
					Scene.active.createObject(obj, format, null, null, function(mine:Object) {
						object.properties.set("nm", mine);
						entries = Event.get("mineThrow");
						for (e in entries)
							e.onEvent();
					});
				});
			}
		});

		// notifyOnRemove(function() {
		// });
	}
}
