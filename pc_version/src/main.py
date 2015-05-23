# Demonstrates the use of the MixerAsync mixer interface wrapper

import os
import gs
import time
import app_template

app = None
music_channel = None
demo_textures = None
demo_screen_vertices = [gs.Vector3(0, 0, 0.5)]
demo_screen_tex = None
demo_screen_pic = None
demo_screen_width = 400
demo_screen_height = 300

def on_log(msgs):
	for i in range(msgs.GetSize()):
		print(msgs.GetMessage(i))


def on_script_error(event):
	print("Error in script '%s'\n\n%s" % (event.component.GetPath(), event.error))


def init_engine(path_pkg_core):
	# hook the engine log
	gs.GetOnLogSignal().Connect(on_log)

	# create workers for multithreading
	gs.GetTaskSystem().CreateWorkers()

	# mount the system file driver
	gs.GetFilesystem().Mount(gs.StdFileDriver(path_pkg_core), "@core")
	gs.GetFilesystem().Mount(gs.StdFileDriver())

def playMusic():
	global app
	# create an OpenAL mixer and wrap it with the MixerAsync interface
	app.mixer_async.Open()
	future_channel = app.mixer_async.Stream(os.path.join(os.getcwd(), "res/music_loop.ogg"))
	music_channel = future_channel.get()

def loadTextures():
	global app
	textures = {"bob_ball":None, "bob_torus":None, "checkerboard_strip":None, "logo_mandarine":None, "logo_sys_zoetrope":None, "font_sans_serif":None}
	for texture_name in textures:
		texture_filename = os.path.join("res", texture_name + ".png")
		if (os.path.exists(texture_filename)):
			textures[texture_name] = gs.LoadPicture(texture_filename)
			print("Found texture : ", texture_filename)

	return textures
	# pic = gs.LoadPicture(os.path.join(os.getcwd(), "../_data/owl.jpg"))

def add_camera():
	global app
	node = gs.Node()
	node.SetName("camera")
	transform = gs.Transform()
	transform.SetPosition(gs.Vector3(0, 0, -3))
	node.AddComponent(transform)

	node.AddComponent(gs.Camera())

	app.scene.AddNode(node)

	# add this camera as the current one in scene
	app.scene.SetCurrentCamera(node)

	return node	

def on_frame_complete():
	global app, demo_screen_vertices, demo_screen_tex
	app.renderer.SetBlendFunc(gs.GpuRenderer.BlendSrcAlpha, gs.GpuRenderer.BlendOneMinusSrcAlpha)
	app.renderer.EnableBlending(False)
	app.renderer.BlitTexture(demo_screen_tex, demo_screen_pic)
	app.render_system.DrawSpriteAuto(1, demo_screen_vertices, demo_screen_tex, 1.0)

def update():
	time.sleep(0.1)	

def main():
	global app, demo_screen_tex, demo_screen_pic

	# mount the system file driver
	gs.MountFileDriver(gs.StdFileDriver())

	init_engine("pkg.core")

	app = app_template.AppTemplate()

	app.open_window(1024, 768)
	app.setup_scene()


	camera = add_camera()

	playMusic()

	demo_textures = loadTextures()

	# callback to draw the raycast intersection points in the scene
	app.add_callback_on_frame_complete(on_frame_complete)

	# main texture
	demo_screen_pic = gs.Picture(demo_screen_width, demo_screen_height, gs.Picture.RGBA8)
	demo_screen_pic.ClearRGBA(0, 0, 0, 0)

	demo_screen_tex = app.renderer.NewTexture("demo_screen_texture")
	app.renderer.CreateTexture(demo_screen_tex, demo_screen_pic)

	while app.run(update) and not gs.GetInputSystem().GetDevice("keyboard").IsDown(gs.InputDevice.KeyEscape):
		pass

if __name__ == "__main__":
    main()

