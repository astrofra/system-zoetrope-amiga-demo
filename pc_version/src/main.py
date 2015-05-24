import os
import gs
import screen_size
from demo_simulation import demoSimulation


def main():
	demo = None
	demo_screen_width = 400
	demo_screen_height = 300	

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
	demo = demoSimulation()

	demo_screen_pic = gs.Picture(demo_screen_width, demo_screen_height, gs.Picture.RGBA8)
	demo_screen_pic.ClearRGBA(1, 0, 1, 1)	

	demo.loadTextures()
	demo_screen_tex = egl.NewTexture("demo_screen_texture")

	# drawMandarineLogo(demo_textures["logo_mandarine"], demo_screen_pic, 0, 16)
	demo.drawMandarineLogo("logo_sys_zoetrope", demo_screen_pic, 0, 0)
	demo.drawCheckerboard(demo_screen_pic, 0)
	for i in range(0,360):
		demo.drawUnlimitedBobs(demo_screen_pic)
	gs.SavePicture(demo_screen_pic, "output.png", "STB", "format:png")

	res = egl.CreateTexture(demo_screen_tex, demo_screen_pic)
	# res = egl.CreateTexture(demo_screen_tex, demo_screen_pic.GetWidth(), demo_screen_pic.GetHeight())
	print("CreateTexture() returned ", res)

	demo_screen_vertices = [gs.Vector3(0, 0, 0.5)]

	while egl.GetDefaultOutputWindow():
		# egl.Clear(gs.Color.Black)
		egl.Clear(gs.Color(1, 0, 0.5, 1))

		# sys.DrawLineAutoRGB(1, [gs.Vector3(0, 10, 0.5), gs.Vector3(1000, 10, 0.5)], [gs.Color.Red, gs.Color.Red])
		# # draw text
		# font.Write(sys, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", gs.Vector3(0, 10, 0.5))
		# sys.DrawRasterFontBatch()

		egl.SetBlendFunc(gs.GpuRenderer.BlendSrcAlpha, gs.GpuRenderer.BlendOneMinusSrcAlpha)
		egl.EnableBlending(True)
		sys.DrawSpriteAuto(1, demo_screen_vertices, demo_screen_tex, 1.0)

		egl.DrawFrame()
		egl.ShowFrame()
		egl.UpdateOutputWindow()

	font = None

if __name__ == "__main__":
    main()

