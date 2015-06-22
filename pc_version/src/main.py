import gs
import screen_size
from demo_simulation import demoSimulation


def main():
	demo = None
	demo_screen_width = 384
	demo_screen_height = 280

	# mount the system file driver
	gs.GetFilesystem().Mount(gs.StdFileDriver("pkg.core"), "@core")
	gs.MountFileDriver(gs.StdFileDriver())

	# create the renderer and render system
	egl = gs.EglRenderer()
	egl.Open(1280, 720)

	sys = gs.RenderSystem(egl)
	sys.Initialize()

	# create the font object
	font = gs.RasterFont("@core/fonts/default.ttf", 48, 512)

	# set default render states
	egl.Set2DMatrices()
	egl.EnableBlending(True)
	egl.EnableDepthTest(False)

	# Init demo simulation
	demo = demoSimulation(demo_screen_width, demo_screen_height)

	demo.loadTextures()
	demo_screen_tex = egl.NewTexture("demo_screen_texture")

	res = egl.CreateTexture(demo_screen_tex, demo.screen_pic)
	# res = egl.CreateTexture(demo_screen_tex, demo_screen_pic.GetWidth(), demo_screen_pic.GetHeight())
	print("CreateTexture() returned ", res)

	demo_screen_vertices = [gs.Vector3(0.5 * 1280, 0.5 * 720, 0.5)]

	while egl.GetDefaultOutputWindow():
		# egl.Clear(gs.Color.Black)
		egl.Clear(screen_size.COLOUR_PURPLE_DARK)

		demo.screen_pic.ClearRGBA(screen_size.COLOUR_PURPLE.r, screen_size.COLOUR_PURPLE.g, screen_size.COLOUR_PURPLE.b, 1.0)

		demo.drawPixelArtLogo()
		demo.renderDemoText()
		demo.drawCheckerboard()
		demo.drawUnlimitedBobs()
		egl.BlitTexture(demo_screen_tex, demo.screen_pic)

		egl.SetBlendFunc(gs.GpuRenderer.BlendSrcAlpha, gs.GpuRenderer.BlendOneMinusSrcAlpha)
		egl.EnableBlending(True)
		sys.DrawSpriteAuto(1, demo_screen_vertices, demo_screen_tex, 0.5 * 720)

		egl.DrawFrame()
		egl.ShowFrame()
		egl.UpdateOutputWindow()

	font = None

if __name__ == "__main__":
    main()

