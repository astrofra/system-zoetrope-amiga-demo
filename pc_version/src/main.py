import gs
import screen_size
from demo_simulation import DemoSimulation


def main():
	demo = None
	pc_screen_windowed = True
	pc_screen_width = 1280
	pc_screen_height = 720

	demo_screen_width = 384
	demo_screen_height = 280
	amiga_screen_ratio = demo_screen_height / demo_screen_width

	if pc_screen_windowed:
		pc_screen_width = int(pc_screen_height * (demo_screen_width / demo_screen_height))

	# mount the system file driver
	# gs.GetFilesystem().Mount(gs.StdFileDriver("pkg.core"), "@core")
	gs.MountFileDriver(gs.StdFileDriver())
	gs.LoadPlugins(gs.get_default_plugins_path())

	# create the renderer and render system
	plus = gs.GetPlus()
	plus.RenderInit(pc_screen_width, pc_screen_height)

	egl = plus.GetRenderer()

	# create the font object
	font = gs.RasterFont("@core/fonts/default.ttf", 48, 512)

	# Init demo simulation
	demo = DemoSimulation(demo_screen_width, demo_screen_height)

	demo.load_textures()
	demo_screen_tex = egl.NewTexture("demo_screen_texture")

	res = egl.CreateTexture(demo_screen_tex, demo.screen_pic)
	print("CreateTexture() returned ", res)

	# play music
	al = gs.MixerAsync(gs.ALMixer())
	al.Open()
	channel_state = gs.MixerChannelState(0, 1, gs.MixerRepeat)
	future_channel = al.Stream("res/music_loop.ogg", channel_state)

	while not plus.KeyPress(gs.InputDevice.KeyEscape):
		dt = plus.UpdateClock()
		plus.Clear()

		# Demo simulation (re-creation)
		demo.update_dt(dt.to_sec())
		demo.clear_screen()
		demo.draw_pixel_art_logo()
		demo.draw_checkerboard()
		demo.draw_unlimited_bobs()
		demo.render_demo_text()

		egl.BlitTexture(demo_screen_tex, demo.screen_pic)

		if pc_screen_windowed:
			plus.Quad2D(0, 0, 0, pc_screen_height, pc_screen_width, pc_screen_height,
						pc_screen_width, 0, gs.Color.White, gs.Color.White, gs.Color.White, gs.Color.White,
						demo_screen_tex)
		else:
			_x_offset = (pc_screen_width - pc_screen_width * amiga_screen_ratio) * 0.5
			plus.Quad2D(_x_offset, 0, _x_offset, pc_screen_height, _x_offset + (pc_screen_width * amiga_screen_ratio),
						pc_screen_height, _x_offset + (pc_screen_width * amiga_screen_ratio), 0,
						gs.Color.White, gs.Color.White, gs.Color.White, gs.Color.White, demo_screen_tex)

		plus.Flip()

	font = None

if __name__ == "__main__":
    main()

