package arm;
import iron.object.Object;
import iron.math.Vec4;
import armory.trait.physics.RigidBody;

class Grav extends iron.Trait {

	public var G = 40;

	public function new() {
		super();
		
		var s = new Vec4();  
		var f = new Vec4();
		var rb:RigidBody;		

		 notifyOnInit(function() {
			rb = object.getTrait(RigidBody);
		 });

		 notifyOnUpdate(function() {
		
			f.x=0;f.y=0;f.z=0;
			
			s = object.transform.world.getLoc();
			var co = iron.Scene.active.meshes.length;
			var tmp;
			for (i in 0...co) {
				tmp = iron.Scene.active.getChild(iron.Scene.active.meshes[i].name.toString());
				if (tmp!=object && tmp!=null && tmp.getTrait(RigidBody)!=null) { f.add(c(iron.Scene.active.getChild(iron.Scene.active.meshes[i].name.toString()), s, object, G));}
			}
			if (rb!=null) rb.applyForce(f);	
		 });
	}

	static function c (ob:Object, s:Vec4, so:Object, g:Float):Vec4 {
		var w = new Vec4(); 
		var o = new Vec4(); 
		var rb1:RigidBody;	
		var rb2:RigidBody;	
			rb1 = so.getTrait(RigidBody);	
			rb2 = ob.getTrait(RigidBody);	
			 o = ob.transform.world.getLoc();
			 w.x = o.x - s.x;
			 w.y = o.y - s.y;
			 w.z = o.z - s.z;
			 w.normalize();
		     w.x *= ((rb1.mass*rb2.mass) /(iron.math.Vec4.distance(s,o) * iron.math.Vec4.distance(s,o)))*g;
			 w.y *= ((rb1.mass*rb2.mass) /(iron.math.Vec4.distance(s,o) * iron.math.Vec4.distance(s,o)))*g;
			 w.z *= ((rb1.mass*rb2.mass) /(iron.math.Vec4.distance(s,o) * iron.math.Vec4.distance(s,o)))*g;
			 return w;
		 }
}