package arm.node;

@:keep class NodeTree_001 extends armory.logicnode.LogicTree {

	var functionNodes:Map<String, armory.logicnode.FunctionNode>;

	var functionOutputNodes:Map<String, armory.logicnode.FunctionOutputNode>;

	public function new() {
		super();
		name = "NodeTree_001";
		this.functionNodes = new Map();
		this.functionOutputNodes = new Map();
		notifyOnAdd(add);
	}

	override public function add() {
		var _ApplyImpulse = new armory.logicnode.ApplyImpulseNode(this);
		var _OnInit = new armory.logicnode.OnInitNode(this);
		_OnInit.addOutputs([_ApplyImpulse]);
		_ApplyImpulse.addInput(_OnInit, 0);
		_ApplyImpulse.addInput(new armory.logicnode.ObjectNode(this, ""), 0);
		_ApplyImpulse.addInput(new armory.logicnode.VectorNode(this, 0.0, 109.19999694824219, 0.0), 0);
		_ApplyImpulse.addOutputs([new armory.logicnode.NullNode(this)]);
	}
}