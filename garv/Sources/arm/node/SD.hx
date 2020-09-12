package arm.node;

@:keep class SD extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		name = "SD";
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _RemoveObject = new armory.logicnode.RemoveObjectNode(this);
		var _OnInit = new armory.logicnode.OnInitNode(this);
		_OnInit.addOutputs([_RemoveObject]);
		_RemoveObject.addInput(_OnInit, 0);
		_RemoveObject.addInput(new armory.logicnode.ObjectNode(this, ""), 0);
		_RemoveObject.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}