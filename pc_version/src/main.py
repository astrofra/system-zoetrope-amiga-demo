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

	render.init(640, 400, "../pkg.core")
	gs.MountFileDriver(gs.StdFileDriver())

	scn = scene.new_scene()

	cam = scene.add_camera(scn, gs.Matrix4.TranslationMatrix(gs.Vector3(0, 1, -10)))
	scene.add_light(scn, gs.Matrix4.TranslationMatrix(gs.Vector3(6, 4, -6)))
	scene.add_cube(scn, gs.Matrix4.TranslationMatrix(gs.Vector3(0, 0.5, 0)))
	scene.add_plane(scn)
	demo_screen = scene.add_plane(scn, gs.Matrix4.TranslationMatrix(gs.Vector3(0, 2.0, 0)), 4 * 0.5, 3 * 0.5)
	demo_screen.transform.SetRotation(gs.Vector3(math.pi * -0.5, 0.0, 0.0))

	fps = camera.fps_controller(0, 2, -10)

	# Init demo simulation
	demo = DemoSimulation(demo_screen_width, demo_screen_height)
	demo.load_textures()
	# demo_screen_tex = egl.NewTexture("demo_screen_texture")

	# res = egl.CreateTexture(demo_screen_tex, demo.screen_pic)
	# res = egl.CreateTexture(demo_screen_tex, demo_screen_pic.GetWidth(), demo_screen_pic.GetHeight())

	# print("CreateTexture() returned ", res)

	audio.init()
	audio.get_mixer().Stream("../res/music_loop.ogg")
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
		# egl.BlitTexture(demo_screen_tex, demo.screen_pic)

		fps.update_and_apply_to_node(cam, dt_sec)

		scene.update_scene(scn, dt_sec)
		render.text2d(5, 5, "Move around with QSZD, left mouse button to look around")
		render.flip()

	font = None

if __name__ == "__main__":
    main()
