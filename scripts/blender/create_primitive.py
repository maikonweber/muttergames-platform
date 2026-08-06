"""Cria uma malha low-poly e exporta GLB; execute apenas dentro do Blender."""
import argparse
import os
import sys
import bpy


def arguments():
    raw = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--shape", choices=["cube", "sphere", "cylinder"], required=True)
    parser.add_argument("--name", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--color", default="55D9FF")
    return parser.parse_args(raw)


def color_from_hex(value):
    value = value.lstrip("#")
    if len(value) != 6:
        raise ValueError("A cor deve conter 6 dígitos hexadecimais")
    return tuple(int(value[index : index + 2], 16) / 255 for index in (0, 2, 4)) + (1.0,)


def main():
    args = arguments()
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    if args.shape == "cube":
        bpy.ops.mesh.primitive_cube_add()
    elif args.shape == "sphere":
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=3)
    else:
        bpy.ops.mesh.primitive_cylinder_add(vertices=12)
    asset = bpy.context.active_object
    asset.name = args.name
    material = bpy.data.materials.new(f"{args.name}_material")
    material.diffuse_color = color_from_hex(args.color)
    asset.data.materials.append(material)
    bpy.ops.object.shade_smooth()
    output = os.path.abspath(args.output)
    os.makedirs(os.path.dirname(output), exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=output, export_format="GLB", use_selection=True)
    print(f"MUTTER_FORGE_OUTPUT={output}")


if __name__ == "__main__":
    main()
