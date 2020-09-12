bl_info = {
    "name": "Game Export",
    "blender": (2, 80, 0),
    "category": "Import-Export",
}

import bpy
import json
import os
from bpy.utils import register_class, unregister_class
from bpy.props import *

class doExport(bpy.types.Operator):
    """Export Game Data alongside .blend"""
    bl_idname = 'object.do_export'
    bl_label = 'Export'
    bl_options = {"REGISTER", "UNDO"}
 
    def execute(self, context):
        if (bpy.data.is_saved):
            obs = []
            scene = context.scene
            for obj in scene.objects:
                if obj.type == "MESH": 
                    obProp = obj.ObjectGEProps
                    obs.append({
                        "name": obj.name,
                        "jump": obProp.ge_jump,
                        "boost": obProp.ge_boost,
                        "gx": obProp.ge_grav[0],
                        "gy": obProp.ge_grav[1],
                        "gz": obProp.ge_grav[2],
                    })
            # encode data as JSON 
            data = json.dumps(obs, indent=1, ensure_ascii=True)

            # set output path and file name
            save_path = bpy.path.basename("//")
            file_name = os.path.join(save_path, bpy.path.basename(bpy.context.blend_data.filepath)[:-6]+".json")

            # write JSON file
            with open(file_name, 'w') as outfile:
                outfile.write(data + '\n')
            return {"FINISHED"}
        else:
            self.report({"WARNING"}, "You need to safe first")
        return {"CANCELLED"}
 
def register() :
    bpy.utils.register_class(doExport)
 
def unregister() :
    bpy.utils.unregister_class(doExport)

class GameExport(bpy.types.Panel):
    """Game Export"""
    bl_idname = "object.game_export"
    bl_label = "Game Export"
    bl_space_type = "PROPERTIES"
    bl_region_type = "WINDOW"
    bl_context = "render"
    bl_options = {'DEFAULT_CLOSED'}

    def draw(self, context):
        layout = self.layout
        
        row = layout.row(align=True)
        row.alignment = 'EXPAND'
        row.operator("object.do_export", icon="PLAY")

class ObjectGES(bpy.types.Panel):
    """Game Export Settings"""
    bl_idname = "object.game_export_settings"
    bl_label = "Game Export Settings"
    bl_space_type = "PROPERTIES"
    bl_region_type = "WINDOW"
    bl_context = "object"
    bl_options = {'DEFAULT_CLOSED'}

    def draw(self, context):
        layout = self.layout
        scene = context.scene
        obj = bpy.context.object
        layout.use_property_split = True
        layout.use_property_decorate = False
        scene = context.scene
        
        if obj.type == "MESH":
            row = layout.row(align=False)
            row.prop(obj.ObjectGEProps, "ge_jump")
            row = layout.row(align=False)
            row.prop(obj.ObjectGEProps, "ge_boost")
            row = layout.row(align=False)
            row.prop(obj.ObjectGEProps, "ge_grav")

class ObjectGEProps(bpy.types.PropertyGroup):
    ge_jump : FloatProperty(
        name = "Jump",
        default = 0,
        min = 0.0
    )
    ge_boost : FloatProperty(
        name = "Boost",
        default = 0
    )
    ge_grav : FloatVectorProperty(
        name = "Gravity",
        default = (0,0,0)
    )

def register():
    register_class(doExport)
    register_class(GameExport)
    register_class(ObjectGES)
    register_class(ObjectGEProps)
    bpy.types.Object.ObjectGEProps = bpy.props.PointerProperty(type=ObjectGEProps)

def unregister():
    unregister_class(ObjectGES)
    unregister_class(ObjectGEProps)
    unregister_class(GameExport)
    unregister_class(doExport)
    del bpy.types.Object.ObjectGEProps