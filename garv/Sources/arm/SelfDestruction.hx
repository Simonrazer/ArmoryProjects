package arm;

class SelfDestruction extends iron.Trait {
	public function new() {
		super();

		 notifyOnInit(function() {
			 object.remove();
		 });

		// notifyOnUpdate(function() {
		// });

		// notifyOnRemove(function() {
		// });
	}
}
