package arm;

import armory.trait.physics.RigidBody;

class MyTrait extends iron.Trait {
	public function new() {
		super();

		var rb:RigidBody;
		notifyOnInit(function() {
			rb = object.getTrait(RigidBody);
		});

		notifyOnUpdate(function() {});

		// notifyOnRemove(function() {
		// });
	}
}
