package arm;
import iron.object.Object;
import iron.math.Vec4;
import armory.trait.physics.RigidBody;

class MyTrait extends iron.Trait {
	public function new() {
		super();

		// notifyOnInit(function() {
		// });

		 notifyOnUpdate(function() {
			 trace (iron.Scene.active.meshes.length);
		 });

		// notifyOnRemove(function() {
		// });
	}
}