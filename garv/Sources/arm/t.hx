package arm;
import iron.object.Object;
import iron.math.Vec4;
import armory.trait.physics.RigidBody;

class t extends iron.Trait {
	public function new() {
		super();

		// notifyOnInit(function() {
		// });

		 notifyOnUpdate(function() {
			 return iron.Scene.active;
		 });

		// notifyOnRemove(function() {
		// });
	}
}
