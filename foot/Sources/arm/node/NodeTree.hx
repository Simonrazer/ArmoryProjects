package arm.node;

@:keep class NodeTree extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		name = "NodeTree";
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _RotateObject = new armory.logicnode.RotateObjectNode(this);
		_RotateObject.property0 = "Euler Angles";
		var _OnUpdate = new armory.logicnode.OnUpdateNode(this);
		_OnUpdate.property0 = "Update";
		_OnUpdate.addOutputs([_RotateObject]);
		_RotateObject.addInput(_OnUpdate, 0);
		_RotateObject.addInput(new armory.logicnode.ObjectNode(this, "Suzanne.001"), 0);
		_RotateObject.addInput(new armory.logicnode.VectorNode(this, 0.19999998807907104, 0.09999999403953552, 0.09999999403953552), 0);
		_RotateObject.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}