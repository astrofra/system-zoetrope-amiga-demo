import os
import gs
import screen_size
import math
import font_desc

class demoSimulation:
	def __init__(self, demo_screen_width, demo_screen_height):

		self.dt = 1.0 / 60.0

		self.demo_screen_width = demo_screen_width
		self.demo_screen_height = demo_screen_height
		self.pictures = None
		self.screen_tex = None
		self.ubob_phase_x = 0
		self.ubob_phase_y = 0
		self.frame = 0

		self.x_margin = int((self.demo_screen_width - screen_size.DISPL_WIDTH2) / 2.0)

		#	Main screen
		self.screen_pic = gs.Picture(demo_screen_width, demo_screen_height, gs.Picture.RGBA8)
		self.screen_pic.ClearRGBA(1, 0, 1, 1)

		#	Logos
		self.logo_mode = "FADEIN"
		self.logo_offset_phase = 0
		self.logo_picture_name = "logo_sys_zoetrope"
		self.logo_alpha = 0.0
		self.logo_display_timer = 0.0

		#	Unlimited bob fx
		self.ubob_frame = 0
		self.ubob_buffer = gs.Picture(screen_size.WIDTH2, screen_size.HEIGHT2, gs.Picture.RGBA8)
		self.ubob_buffer.ClearRGBA(0, 0, 0, 0)
		self.ubob_offset_phase = 0

		#	Font writer
		self.text_buffer = gs.Picture(screen_size.WIDTH3, screen_size.HEIGHT3, gs.Picture.RGBA8)
		self.text_buffer.ClearRGBA(0, 0, 0, 0)
		self.current_text_idx = 0
		self.text_drawn_on_top = True
		self.text_display_timer = 0.0

	def loadTextures(self):
		self.pictures = {
							"bob_ball":None, "bob_torus":None, 
							"checkerboard_strip":None, "copper_list":None,
							"logo_mandarine":None, "logo_sys_zoetrope":None, 
							"font_sans_serif":None
						}

		for texture_name in self.pictures:
			texture_filename = os.path.join("res", texture_name + ".png")
			if (os.path.exists(texture_filename)):
				self.pictures[texture_name] = gs.LoadPicture(texture_filename)
				print("Found texture : ", texture_filename)

		if self.pictures["checkerboard_strip"] is not None:
			pixel_data = self.pictures["checkerboard_strip"].GetData()
			print("len(pixel_data) = ", len(pixel_data))
			w = self.pictures["checkerboard_strip"].GetWidth()
			h = self.pictures["checkerboard_strip"].GetHeight()

			for strip_idx in range(0, screen_size.ANIM_STRIPE):
				for y in range(0, int(h / screen_size.ANIM_STRIPE)):
					cl_pixel = self.pictures["copper_list"].GetPixelRGBA(8, y + screen_size.DISPL_HEIGHT2 - screen_size.CHECKERBOARD_HEIGHT + 21 - 16) / 255.0
					for x in range(0, w):
						cb_pixel = self.pictures["checkerboard_strip"].GetPixelRGBA(x, int(y + strip_idx * (h / screen_size.ANIM_STRIPE))) / 255.0

						cb_luma = pow(cb_pixel.x, 0.5) * 0.3 + max(0, cl_pixel.x - 0.25)
						# print("cb_luma = " + str(cb_luma))
						cb_pixel.x = min(1.0, cb_pixel.x * cb_luma + cl_pixel.x * (1.0 - cb_luma))
						cb_pixel.y = min(1.0, cb_pixel.y * cb_luma + cl_pixel.y * (1.0 - cb_luma))
						cb_pixel.z = min(1.0, cb_pixel.z * cb_luma + cl_pixel.z * (1.0 - cb_luma))

						cb_pixel.x = min(1.0, cb_pixel.x + max(0, (cl_pixel.x - screen_size.COLOUR_PURPLE.r) * cb_luma))
						cb_pixel.y = min(1.0, cb_pixel.y + max(0, (cl_pixel.y - screen_size.COLOUR_PURPLE.g) * cb_luma))
						cb_pixel.z = min(1.0, cb_pixel.z + max(0, (cl_pixel.z - screen_size.COLOUR_PURPLE.b) * cb_luma))

						# cb_pixel.x = cb_pixel.x * (1.0 - (16.0 / 255.0)) + gs.Color(0x22 / 255.0, 0xAA / 255.0, 0xFF / 255.0).r * (16.0 / 255.0)
						# cb_pixel.x = cb_pixel.y * (1.0 - (16.0 / 255.0)) + gs.Color(0x22 / 255.0, 0xAA / 255.0, 0xFF / 255.0).g * (16.0 / 255.0)
						# cb_pixel.x = cb_pixel.z * (1.0 - (16.0 / 255.0)) + gs.Color(0x22 / 255.0, 0xAA / 255.0, 0xFF / 255.0).b * (16.0 / 255.0)

						cb_pixel.x = min(1.0, cb_pixel.x)
						cb_pixel.y = min(1.0, cb_pixel.y)
						cb_pixel.z = min(1.0, cb_pixel.z)								

						cb_pixel.w = 1.0
						self.pictures["checkerboard_strip"].PutPixelRGBA(x, int(y + strip_idx * (h / screen_size.ANIM_STRIPE)), cb_pixel.x, cb_pixel.y, cb_pixel.z, cb_pixel.w)

	def drawPixelArtLogo(self):
		if self.logo_mode == "FADEIN":
			self.logo_alpha += self.dt * 10.0

			if self.logo_alpha > 1.0:
				self.logo_alpha = 1.0
				self.logo_display_timer = 0.0
				self.logo_mode = "DISPLAY_LOGO"

		if self.logo_mode == "DISPLAY_LOGO":
			self.logo_display_timer += self.dt * 10.0
			if self.logo_display_timer > 100.0:
				self.logo_alpha = 1.0
				self.logo_mode = "FADEOUT"

		if self.logo_mode == "FADEOUT":
			self.logo_alpha -= self.dt * 10.0

			if self.logo_alpha < 0.0:
				self.logo_alpha = 0.0
				self.logo_mode = "CHANGE_LOGO"

		if self.logo_mode == "CHANGE_LOGO":
			if self.logo_picture_name == "logo_sys_zoetrope":
				self.logo_picture_name = "logo_mandarine"
			else:
				self.logo_picture_name = "logo_sys_zoetrope"

			self.logo_mode = "FADEIN"

		logo_pic = self.pictures[self.logo_picture_name]
		src_rect = logo_pic.GetRect()
		if self.logo_picture_name == "logo_sys_zoetrope":
			x_margin = (self.demo_screen_width - src_rect.GetWidth()) / 2.0
			offset_x = (math.sin(math.radians(self.logo_offset_phase)) + 1.0) * x_margin
		else:
			x_margin = 32.0
			offset_x = math.sin(math.radians(self.logo_offset_phase)) * x_margin

		offset_y = 0
		self.screen_pic.Blit(logo_pic, src_rect, gs.iVector2(int(offset_x), int(offset_y)))

		## Fade in using a blended rect
		if self.logo_alpha < 1.0:
			self.screen_pic.SetFillMode(gs.Picture.BrushSolid)
			self.screen_pic.SetPenMode(gs.Picture.PenNone)
			self.screen_pic.SetFillColorRGBA(screen_size.COLOUR_PURPLE.r, screen_size.COLOUR_PURPLE.g, screen_size.COLOUR_PURPLE.b, 1.0 - self.logo_alpha)
			src_rect.SetWidth(self.demo_screen_width)
			self.screen_pic.DrawRect(src_rect.sx, src_rect.sy, src_rect.ex, src_rect.ey)

		self.logo_offset_phase += 120.0 * self.dt

	def drawCheckerboard(self):
		# Draw the copper list
		copper_pic = self.pictures["copper_list"]
		offset_y = screen_size.DISPL_HEIGHT1 + screen_size.DISPL_HEIGHT3 + 16
		source_rect = copper_pic.GetRect()
		for i in range(0, int(self.demo_screen_width / source_rect.GetWidth())):
			self.screen_pic.Blit(copper_pic, source_rect, gs.iVector2(i * source_rect.GetWidth(), offset_y))

		# Draw the checkboard
		checker_pic = self.pictures["checkerboard_strip"]

		dest_rect = checker_pic.GetRect()
		dest_rect.SetHeight(screen_size.CHECKERBOARD_HEIGHT)
		dest_rect = dest_rect.Offset(self.x_margin, screen_size.DISPL_HEIGHT2 + screen_size.DISPL_HEIGHT3)

		src_matrix = gs.Matrix3.TranslationMatrix(gs.Vector2(-self.x_margin, (int(self.frame)%screen_size.ANIM_STRIPE) * screen_size.CHECKERBOARD_HEIGHT - dest_rect.sy))

		self.screen_pic.BlitTransform(checker_pic, dest_rect, src_matrix, gs.Picture.Nearest)

		self.frame += (30.0 * self.dt) ##(self.frame + 1)%screen_size.ANIM_STRIPE

	def drawUnlimitedBobs(self, figure_mode = 0):
		x = 0
		y = 0

		bob_pic = self.pictures["bob_ball"]

		##	Lissajous trajectory
		phase_scaler = 0.5
		self.ubob_phase_x += 180 * self.dt
		self.ubob_phase_y += 120 * self.dt

		x = (screen_size.DISPL_WIDTH2b - screen_size.DISPL_WIDTH2b * 0.8 + bob_pic.GetRect().GetWidth()) * 0.5 + (math.cos(math.radians(self.ubob_phase_x) * phase_scaler) + 1.0 * 0.5) * screen_size.DISPL_WIDTH2b * 0.5 * 0.8
		y = (math.sin(math.radians(self.ubob_phase_y) * phase_scaler) + 1.0 * 0.5) * screen_size.DISPL_HEIGHT2b * 0.5 * 0.8

		x += bob_pic.GetRect().GetWidth()
		y += bob_pic.GetRect().GetHeight()

		# y += screen_size.DISPL_HEIGHT1 + screen_size.DISPL_HEIGHT3
		y += self.ubob_frame * screen_size.DISPL_HEIGHT2
		x = int(x)
		y = int(y)

		# x = ((WIDTH2b - DISPL_WIDTH2b) >> 1) + 24 + ubob_scale + (((tcos[ubob_phase_x & 0x1FF] + 512) * (DISPL_WIDTH2b - 8 - 64 - ubob_scale - ubob_scale)) >> 10);
		#  y = 8 + ubob_scale + (((tsin[ubob_phase_y & 0x1FF] + 512) * (DISPL_HEIGHT2b - 16 - 32 - ubob_scale - ubob_scale)) >> 10);

		offset_x = math.sin(math.radians(self.ubob_offset_phase)) * 32.0 + self.x_margin

		dest_rect = bob_pic.GetRect()
		self.ubob_buffer.Blit(bob_pic, dest_rect, gs.iVector2(x, y))

		dest_rect = self.ubob_buffer.GetRect()
		dest_rect.SetHeight(screen_size.DISPL_HEIGHT2)
		# dest_rect = gs.iRect(screen_size.DISPL_WIDTH2, screen_size.DISPL_HEIGHT2)
		dest_rect = dest_rect.Offset(0, self.ubob_frame * screen_size.DISPL_HEIGHT2)
		self.screen_pic.Blit(self.ubob_buffer, dest_rect, gs.iVector2(int(offset_x), screen_size.DISPL_HEIGHT1 + screen_size.DISPL_HEIGHT3))

		# self.screen_pic.Blit(bob_pic, dest_rect, gs.iVector2(x, y))

		self.ubob_frame = (self.ubob_frame + 1)%screen_size.ANIM_STRIPE
		self.ubob_offset_phase += 120.0 * self.dt

		# print("clock = " + str(self.clock.GetDelta().to_sec()))

	def renderDemoText(self):
		if self.current_text_idx == -1 or self.text_display_timer > len(font_desc.demo_string[self.current_text_idx]) * 0.05:
			self.text_display_timer = 0.0
			self.current_text_idx += 1
			if self.current_text_idx >= len(font_desc.demo_string):
				self.current_text_idx = 0
			text_str = font_desc.demo_string[self.current_text_idx]

			print("text_str = " + text_str)

		self.text_display_timer += self.dt

