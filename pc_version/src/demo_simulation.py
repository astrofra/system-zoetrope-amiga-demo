import os
import gs
import screen_size
import math

class demoSimulation:
	def __init__(self):
		self.textures = None
		self.screen_tex = None
		self.ubob_phase_x = 0
		self.ubob_phase_y = 0
		self.frame = 0

	def loadTextures(self):
		self.textures = {
							"bob_ball":None, "bob_torus":None, 
							"checkerboard_strip":None, "copper_list":None,
							"logo_mandarine":None, "logo_sys_zoetrope":None, 
							"font_sans_serif":None
						}

		for texture_name in self.textures:
			texture_filename = os.path.join("res", texture_name + ".png")
			if (os.path.exists(texture_filename)):
				self.textures[texture_name] = gs.LoadPicture(texture_filename)
				print("Found texture : ", texture_filename)

		if self.textures["checkerboard_strip"] is not None:
			pixel_data = self.textures["checkerboard_strip"].GetData()
			print("len(pixel_data) = ", len(pixel_data))
			w = self.textures["checkerboard_strip"].GetWidth()
			h = self.textures["checkerboard_strip"].GetHeight()

			for strip_idx in range(0, screen_size.ANIM_STRIPE - 1):
				for y in range(0, int(h / screen_size.ANIM_STRIPE)):
					cl_pixel = self.textures["copper_list"].GetPixelRGBA(8, y + screen_size.DISPL_HEIGHT2 - 100 + 21) / 255.0
					for x in range(0, w):
						cb_pixel = self.textures["checkerboard_strip"].GetPixelRGBA(x, int(y + strip_idx * (h / screen_size.ANIM_STRIPE))) / 255.0
						cb_pixel.x = min(1.0, cb_pixel.x + cl_pixel.x)
						cb_pixel.y = min(1.0, cb_pixel.y + cl_pixel.y)
						cb_pixel.z = min(1.0, cb_pixel.z + cl_pixel.z)
						cb_pixel.w = 1.0
						self.textures["checkerboard_strip"].PutPixelRGBA(x, int(y + strip_idx * (h / screen_size.ANIM_STRIPE)), cb_pixel.x, cb_pixel.y, cb_pixel.z, cb_pixel.w)

	def drawMandarineLogo(self, logo_pic_name, dest_pic, offset_x = 0, offset_y = 0):
		logo_pic = self.textures[logo_pic_name]
		dest_pic.Blit(logo_pic, logo_pic.GetRect().Offset(offset_x, offset_y), gs.Matrix3.TranslationMatrix(gs.Vector3(-offset_x, -offset_y, 0)), True)

	def drawCheckerboard(self, dest_pic):
		# Draw the copper list
		copper_pic = self.textures["copper_list"]
		offset_y = screen_size.DISPL_HEIGHT1 + screen_size.DISPL_HEIGHT3
		source_rect = copper_pic.GetRect()
		dest_rect = source_rect.Offset(0, offset_y)
		dest_rect.SetWidth(dest_pic.GetWidth())
		# dest_pic.Blit(copper_pic, dest_rect, gs.Matrix3.TranslationMatrix(gs.Vector3(0, -offset_y, 0)), False)
		dest_pic.BlitStretch(copper_pic, source_rect, dest_rect, True) 

		# Draw the checkboard
		checker_pic = self.textures["checkerboard_strip"]
		offset_y = (self.frame%screen_size.ANIM_STRIPE) * 100 + screen_size.DISPL_HEIGHT2 + screen_size.DISPL_HEIGHT3
		dest_rect = checker_pic.GetRect()
		dest_rect.SetHeight(100)
		dest_rect = dest_rect.Offset(0, offset_y)
		dest_pic.Blit(checker_pic, dest_rect, gs.Matrix3.TranslationMatrix(gs.Vector3(0, -offset_y, 0)), True)

		self.frame = 0

	def drawUnlimitedBobs(self, dest_pic, figure_mode = 0):
		x = 0
		y = 0

		bob_pic = self.textures["bob_ball"]

		##	Lissajous trajectory
		self.ubob_phase_x += 3
		self.ubob_phase_y += 2

		x = (screen_size.DISPL_WIDTH2b - screen_size.DISPL_WIDTH2b * 0.8 + bob_pic.GetRect().GetWidth()) * 0.5 + (math.cos(math.radians(self.ubob_phase_x)) + 1.0 * 0.5) * screen_size.DISPL_WIDTH2b * 0.5 * 0.8
		y = (math.sin(math.radians(self.ubob_phase_y)) + 1.0 * 0.5) * screen_size.DISPL_HEIGHT2b * 0.5 * 0.8

		x += bob_pic.GetRect().GetWidth()
		y += bob_pic.GetRect().GetHeight()

		y += screen_size.DISPL_HEIGHT1 + screen_size.DISPL_HEIGHT3
		x = int(x)
		y = int(y)

    # x = ((WIDTH2b - DISPL_WIDTH2b) >> 1) + 24 + ubob_scale + (((tcos[ubob_phase_x & 0x1FF] + 512) * (DISPL_WIDTH2b - 8 - 64 - ubob_scale - ubob_scale)) >> 10);
    # y = 8 + ubob_scale + (((tsin[ubob_phase_y & 0x1FF] + 512) * (DISPL_HEIGHT2b - 16 - 32 - ubob_scale - ubob_scale)) >> 10);

		dest_rect = bob_pic.GetRect()
		dest_rect = dest_rect.Offset(x, y)
		dest_pic.Blit(bob_pic, dest_rect, gs.Matrix3.TranslationMatrix(gs.Vector3(-x, -y, 0)), False)