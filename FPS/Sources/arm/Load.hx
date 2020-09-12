package arm;

import haxe.Json;
import iron.data.MaterialData;
import kha.arrays.Uint32Array;
import kha.arrays.Float32Array;
import kha.arrays.Int16Array;
import iron.Scene;
import iron.object.Object;
import iron.object.MeshObject;
import iron.data.MeshData;
import iron.data.SceneFormat;
import iron.data.Data;
import iron.math.Vec4;
import iron.math.Mat4;
import iron.math.Quat;
import iron.system.Input;

class Load extends iron.Trait {
	var data:Dynamic;

	public function new() {
		super();
		notifyOnUpdate(function() {
			var mouse = Input.getMouse();

			if (mouse.started("left")) {
				// Import Extra Data
				kha.Assets.loadBlobFromPath("test.json", function(b:kha.Blob) {
					data = Json.parse(b.toString());

					// Import and parse .blend. THIS IS NONE OF MY WORK, THIS IS COPIED FROM ARMORPAINT
					var parseVCols = false;
					kha.Assets.loadBlobFromPath("test.blend", function(b:kha.Blob) {
						var bl = new BlendParser(b);
						var obs = bl.get("Object");
						var first = true;
						for (ob in obs) {
							if (ob.get("type") != 1)
								continue;
							var obLoc = ob.get("dloc");
							var obRot = ob.get("drot");

							var name:String = ob.get("id").get("name");
							name = name.substring(2, name.length);

							var m:Dynamic = ob.get("data", 0, "Mesh");
							if (m == null)
								continue;

							var totpoly = m.get("totpoly");
							if (totpoly == 0)
								continue;

							var numtri = 0;
							for (i in 0...totpoly) {
								var poly = m.get("mpoly", i);
								var totloop = poly.get("totloop");
								numtri += totloop - 2;
							}
							var inda = new Uint32Array(numtri * 3);
							for (i in 0...inda.length)
								inda[i] = i;

							var posa32 = new Float32Array(numtri * 3 * 4);
							var posa = new Int16Array(numtri * 3 * 4);
							var nora = new Int16Array(numtri * 3 * 2);
							var hasuv = m.get("mloopuv") != null;
							var texa = hasuv ? new Int16Array(numtri * 3 * 2) : null;
							var hascol = parseVCols && m.get("mloopcol") != null;
							var cola = hascol ? new Int16Array(numtri * 3 * 3) : null;

							var tri = 0;
							var vec0 = new Vec4();
							var vec1 = new Vec4();
							var vec2 = new Vec4();
							for (i in 0...totpoly) {
								var poly = m.get("mpoly", i);
								var loopstart = poly.get("loopstart");
								var totloop = poly.get("totloop");
								if (totloop == 3) {
									var v0 = m.get("mvert", m.get("mloop", loopstart).get("v"));
									var v1 = m.get("mvert", m.get("mloop", loopstart + 1).get("v"));
									var v2 = m.get("mvert", m.get("mloop", loopstart + 2).get("v"));
									var co0 = v0.get("co");
									var co1 = v1.get("co");
									var co2 = v2.get("co");
									var no0 = v0.get("no");
									var no1 = v1.get("no");
									var no2 = v2.get("no");
									vec0.set(no0[0] / 32767, no0[1] / 32767, no0[2] / 32767).normalize(); // shortmax
									vec1.set(no1[0] / 32767, no1[1] / 32767, no1[2] / 32767).normalize();
									vec2.set(no2[0] / 32767, no2[1] / 32767, no2[2] / 32767).normalize();
									posa32[tri * 9] = co0[0];
									posa32[tri * 9 + 1] = co0[1];
									posa32[tri * 9 + 2] = co0[2];
									posa32[tri * 9 + 3] = co1[0];
									posa32[tri * 9 + 4] = co1[1];
									posa32[tri * 9 + 5] = co1[2];
									posa32[tri * 9 + 6] = co2[0];
									posa32[tri * 9 + 7] = co2[1];
									posa32[tri * 9 + 8] = co2[2];
									posa[tri * 12 + 3] = Std.int(vec0.z * 32767);
									posa[tri * 12 + 7] = Std.int(vec1.z * 32767);
									posa[tri * 12 + 11] = Std.int(vec2.z * 32767);
									nora[tri * 6] = Std.int(vec0.x * 32767);
									nora[tri * 6 + 1] = Std.int(vec0.y * 32767);
									nora[tri * 6 + 2] = Std.int(vec1.x * 32767);
									nora[tri * 6 + 3] = Std.int(vec1.y * 32767);
									nora[tri * 6 + 4] = Std.int(vec2.x * 32767);
									nora[tri * 6 + 5] = Std.int(vec2.y * 32767);
									if (hasuv) {
										var uv0:Float32Array = m.get("mloopuv", loopstart).get("uv");
										var uv1:Float32Array = m.get("mloopuv", loopstart + 1).get("uv");
										var uv2:Float32Array = m.get("mloopuv", loopstart + 2).get("uv");
										texa[tri * 6] = Std.int(uv0[0] * 32767);
										texa[tri * 6 + 1] = Std.int((1.0 - uv0[1]) * 32767);
										texa[tri * 6 + 2] = Std.int(uv1[0] * 32767);
										texa[tri * 6 + 3] = Std.int((1.0 - uv1[1]) * 32767);
										texa[tri * 6 + 4] = Std.int(uv2[0] * 32767);
										texa[tri * 6 + 5] = Std.int((1.0 - uv2[1]) * 32767);
									}
									if (hascol) {
										var loop = m.get("mloopcol", loopstart);
										var col0r:Int = loop.get("r");
										var col0g:Int = loop.get("g");
										var col0b:Int = loop.get("b");
										loop = m.get("mloopcol", loopstart + 1);
										var col1r:Int = loop.get("r");
										var col1g:Int = loop.get("g");
										var col1b:Int = loop.get("b");
										loop = m.get("mloopcol", loopstart + 2);
										var col2r:Int = loop.get("r");
										var col2g:Int = loop.get("g");
										var col2b:Int = loop.get("b");
										cola[tri * 9] = col0r * 128;
										cola[tri * 9 + 1] = col0g * 128;
										cola[tri * 9 + 2] = col0b * 128;
										cola[tri * 9 + 3] = col1r * 128;
										cola[tri * 9 + 4] = col1g * 128;
										cola[tri * 9 + 5] = col1b * 128;
										cola[tri * 9 + 6] = col2r * 128;
										cola[tri * 9 + 7] = col2g * 128;
										cola[tri * 9 + 8] = col2b * 128;
									}
									tri++;
								} else {
									var v0 = m.get("mvert", m.get("mloop", loopstart + totloop - 1).get("v"));
									var v1 = m.get("mvert", m.get("mloop", loopstart).get("v"));
									var co0 = v0.get("co");
									var co1 = v1.get("co");
									var no0 = v0.get("no");
									var no1 = v1.get("no");
									vec0.set(no0[0] / 32767, no0[1] / 32767, no0[2] / 32767).normalize(); // shortmax
									vec1.set(no1[0] / 32767, no1[1] / 32767, no1[2] / 32767).normalize();
									var uv0:Float32Array = null;
									var uv1:Float32Array = null;
									var uv2:Float32Array = null;
									if (hasuv) {
										uv0 = m.get("mloopuv", loopstart + totloop - 1).get("uv");
										uv1 = m.get("mloopuv", loopstart).get("uv");
									}
									var col0r:Int = 0;
									var col0g:Int = 0;
									var col0b:Int = 0;
									var col1r:Int = 0;
									var col1g:Int = 0;
									var col1b:Int = 0;
									var col2r:Int = 0;
									var col2g:Int = 0;
									var col2b:Int = 0;
									if (hascol) {
										var loop = m.get("mloopcol", loopstart + totloop - 1);
										col0r = loop.get("r");
										col0g = loop.get("g");
										col0b = loop.get("b");
										loop = m.get("mloopcol", loopstart);
										col1r = loop.get("r");
										col1g = loop.get("g");
										col1b = loop.get("b");
									}
									for (j in 0...totloop - 2) {
										var v2 = m.get("mvert", m.get("mloop", loopstart + j + 1).get("v"));
										var co2 = v2.get("co");
										var no2 = v2.get("no");
										vec2.set(no2[0] / 32767, no2[1] / 32767, no2[2] / 32767).normalize();
										posa32[tri * 9] = co0[0];
										posa32[tri * 9 + 1] = co0[1];
										posa32[tri * 9 + 2] = co0[2];
										posa32[tri * 9 + 3] = co1[0];
										posa32[tri * 9 + 4] = co1[1];
										posa32[tri * 9 + 5] = co1[2];
										posa32[tri * 9 + 6] = co2[0];
										posa32[tri * 9 + 7] = co2[1];
										posa32[tri * 9 + 8] = co2[2];
										posa[tri * 12 + 3] = Std.int(vec0.z * 32767);
										posa[tri * 12 + 7] = Std.int(vec1.z * 32767);
										posa[tri * 12 + 11] = Std.int(vec2.z * 32767);
										nora[tri * 6] = Std.int(vec0.x * 32767);
										nora[tri * 6 + 1] = Std.int(vec0.y * 32767);
										nora[tri * 6 + 2] = Std.int(vec1.x * 32767);
										nora[tri * 6 + 3] = Std.int(vec1.y * 32767);
										nora[tri * 6 + 4] = Std.int(vec2.x * 32767);
										nora[tri * 6 + 5] = Std.int(vec2.y * 32767);
										co1 = co2;
										no1 = no2;
										vec1.setFrom(vec2);
										if (hasuv) {
											uv2 = m.get("mloopuv", loopstart + j + 1).get("uv");
											texa[tri * 6] = Std.int(uv0[0] * 32767);
											texa[tri * 6 + 1] = Std.int((1.0 - uv0[1]) * 32767);
											texa[tri * 6 + 2] = Std.int(uv1[0] * 32767);
											texa[tri * 6 + 3] = Std.int((1.0 - uv1[1]) * 32767);
											texa[tri * 6 + 4] = Std.int(uv2[0] * 32767);
											texa[tri * 6 + 5] = Std.int((1.0 - uv2[1]) * 32767);
											uv1 = uv2;
										}
										if (hascol) {
											var loop = m.get("mloopcol", loopstart + j + 1);
											col2r = loop.get("r");
											col2g = loop.get("g");
											col2b = loop.get("b");
											cola[tri * 9] = col0r * 128;
											cola[tri * 9 + 1] = col0g * 128;
											cola[tri * 9 + 2] = col0b * 128;
											cola[tri * 9 + 3] = col1r * 128;
											cola[tri * 9 + 4] = col1g * 128;
											cola[tri * 9 + 5] = col1b * 128;
											cola[tri * 9 + 6] = col2r * 128;
											cola[tri * 9 + 7] = col2g * 128;
											cola[tri * 9 + 8] = col2b * 128;
											col1r = col2r;
											col1g = col2g;
											col1b = col2b;
										}
										tri++;
									}
								}
							}

							// Apply world matrix
							var obmat = ob.get("obmat", 0, "float", 16);
							var mat = iron.math.Mat4.fromFloat32Array(obmat).transpose();
							var v = new iron.math.Vec4();
							for (i in 0...Std.int(posa32.length / 3)) {
								v.set(posa32[i * 3], posa32[i * 3 + 1], posa32[i * 3 + 2]);
								v.applymat4(mat);
								posa32[i * 3] = v.x;
								posa32[i * 3 + 1] = v.y;
								posa32[i * 3 + 2] = v.z;
							}
							mat.getInverse(mat);
							mat.transpose3x3();
							for (i in 0...Std.int(nora.length / 2)) {
								v.set(nora[i * 2] / 32767, nora[i * 2 + 1] / 32767, posa[i * 4 + 3] / 32767);
								v.applymat(mat);
								v.normalize();
								nora[i * 2] = Std.int(v.x * 32767);
								nora[i * 2 + 1] = Std.int(v.y * 32767);
								posa[i * 4 + 3] = Std.int(v.z * 32767);
							}

							// Pack positions to (-1, 1) range
							var scalePos = 0.0;
							for (i in 0...posa32.length) {
								var f = Math.abs(posa32[i]);
								if (scalePos < f)
									scalePos = f;
							}
							var inv = 1 / scalePos;
							for (i in 0...Std.int(posa32.length / 3)) {
								posa[i * 4] = Std.int(posa32[i * 3] * 32767 * inv);
								posa[i * 4 + 1] = Std.int(posa32[i * 3 + 1] * 32767 * inv);
								posa[i * 4 + 2] = Std.int(posa32[i * 3 + 2] * 32767 * inv);
							}

							var obj = {
								posa: posa,
								nora: nora,
								texa: texa,
								cola: cola,
								inda: inda,
								name: name,
								scalePos: scalePos,
								scaleTes: 1.0
							};
							makeMesh(obj, obLoc, obRot, name);
						}
					});
				});
			}
		});
	}

	// Build Mesh from parsed data
	function makeMesh(mesh:Dynamic, loc:Array<Float>, rot:Array<Float>, n:String) {
		var tMesh:TMeshData = {
			name: mesh.name,
			vertex_arrays: [
				{values: mesh.posa, attrib: "pos", data: "short4norm"},
				{values: mesh.nora, attrib: "nor", data: "short2norm"}
			],
			index_arrays: [{values: mesh.inda, material: 0}],
			scale_pos: mesh.scalePos,
		};

		new MeshData(tMesh, function(mdata:MeshData) {
			var materials:haxe.ds.Vector<MaterialData>;
			Data.getMaterial(iron.Scene.active.raw.name, "Default", function(matData:MaterialData) {
				var materials = haxe.ds.Vector.fromData([matData]);
				var newObject = Scene.active.addMeshObject(mdata, materials);
				// Add rigid body trait
				mdata.geom.calculateAABB();
				var aabb = mdata.geom.aabb;
				newObject.name = n;
				newObject.transform.loc.set(loc[0], loc[1], loc[2]);
				newObject.transform.buildMatrix();
				newObject.transform.dim.set(aabb.x, aabb.y, aabb.z);
				newObject.addTrait(new armory.trait.physics.RigidBody(3, [false, false, false, true]));
				// Add Data from .json
				var relData:Dynamic = null;
				for (i in 0...data.length) {
					if (data[i].name == n) {
						relData = data[i];
						break;
					}
				}
				newObject.properties = [];
				if (relData.jump >= 0.1)
					newObject.properties.set("jump", relData.jump);
				if (relData.boost >= 0.1)
					newObject.properties.set("boost", relData.boost);
				if (Math.abs(relData.gx) + Math.abs(relData.gy) + Math.abs(relData.gz) > 0.1) {
					newObject.properties.set("X", relData.gx);
					newObject.properties.set("Y", relData.gy);
					newObject.properties.set("Z", relData.gz);
				}
			});
		});
	}
}
