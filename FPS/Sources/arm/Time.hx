package arm;

class Time extends iron.Trait {
	public function new() {
		super();

		// notifyOnInit(function() {
		// });

		notifyOnUpdate(function() {
			trace(iron.system.Time.delta);
		});

		// notifyOnRemove(function() {
		// });
	}
}
