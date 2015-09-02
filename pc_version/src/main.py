import os
import gs
import gs.plus.render as render
import gs.plus.camera as camera
import gs.plus.geometry as geometry
import gs.plus.input as input
import gs.plus.scene as scene
import gs.plus.clock as clock
import gs.plus.audio as audio
import math
from demo_simulation import DemoSimulation


def main():
	demo = None
	demo_screen_width = 384
	demo_screen_height = 280

	if os.path.exists("pkg.core"):
		render.init(1280, 720, "pkg.core")
	else:
		print("Cannot find pkg.core/")
		exit()

	gs.MountFileDriver(gs.StdFileDriver())

	scn = scene.new_scene()

	cam = scene.add_camera(scn, gs.Matrix4.TranslationMatrix(gs.Vector3(0, 0, 0)))
	scene.add_light(scn, gs.Matrix4.TranslationMatrix(gs.Vector3(6, 4, -6)))
	# scene.add_cube(scn, gs.Matrix4.TranslationMatrix(gs.Vector3(0, 0.5, 0)))
	scene.add_plane(scn)
	# demo_screen = scene.add_plane(scn, gs.Matrix4.TranslationMatrix(gs.Vector3(0, 2.0, 0)), 4 * 0.5, 3 * 0.5, os.path.join("res", "monitor", "monitor_screen.mat"))
	# demo_screen.transform.SetRotation(gs.Vector3(math.pi * -0.5, 0.0, 0.0))

	monitor_geo = render.load_geometry(os.path.join("res", "monitor", "monitor.geo"))
	monitor_node = gs.Node("monitor")
	monitor_transform = gs.Transform()
	monitor_node.AddComponent(monitor_transform)
	monitor_object = gs.Object()
	monitor_object.SetGeometry(monitor_geo)
	monitor_node.AddComponent(monitor_object)
	scn.AddNode(monitor_node)

	monitor_frame_geo = render.load_geometry(os.path.join("res", "monitor", "monitor_frame.geo"))
	monitor_frame_node = gs.Node("monitor_frame")
	monitor_frame_transform = gs.Transform()
	monitor_frame_node.AddComponent(monitor_frame_transform)
	monitor_frame_object = gs.Object()
	monitor_frame_object.SetGeometry(monitor_frame_geo)
	monitor_frame_node.AddComponent(monitor_frame_object)
	scn.AddNode(monitor_frame_node)

	demo_screen_geo = render.load_geometry(os.path.join("res", "monitor", "monitor_screen.geo"))
	demo_screen_node = gs.Node("demo_screen")
	demo_screen_transform = gs.Transform()
	demo_screen_node.AddComponent(demo_screen_transform)
	demo_screen_object = gs.Object()
	demo_screen_object.SetGeometry(demo_screen_geo)
	demo_screen_node.AddComponent(demo_screen_object)
	scn.AddNode(demo_screen_node)
	demo_screen_mat = demo_screen_geo.GetMaterial(0)
	demo_screen_tex = demo_screen_mat.GetTexture("diffuse_map")

	fps = camera.fps_controller(0, 0.5, -3.5)

	# Init demo simulation
	demo = DemoSimulation(demo_screen_width, demo_screen_height)
	demo.load_textures()

	audio.init()
	demo_audio_stream = audio.get_mixer().Stream(os.path.join("res", "music_loop.ogg"))
	channel_state = audio.get_mixer().GetChannelState(demo_audio_stream)
	channel_state.loop_mode = gs.MixerRepeat
	audio.get_mixer().SetChannelState(demo_audio_stream, channel_state)
	plane_angle = 0.0

	while not input.key_press(gs.InputDevice.KeyEscape):
		dt_sec = clock.update()

		# Demo simulation (re-creation)
		demo.dt = dt_sec
		demo.clear_screen()
		demo.draw_pixel_art_logo()
		demo.draw_checkerboard()
		demo.draw_unlimited_bobs()
		demo.render_demo_text()
		render.get_renderer().BlitTexture(demo_screen_tex, demo.screen_pic)

		fps.update_and_apply_to_node(cam, dt_sec)

		scene.update_scene(scn, dt_sec)
		render.text2d(5, 5, "Move around with QSZD, left mouse button to look around")
		render.flip()

	font = None

if __name__ == "__main__":
    main()
