import os
import gs
import screen_size
import math
import font_desc


class DemoSimulation:
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

		# Main screen
		self.screen_pic = gs.Picture(demo_screen_width, demo_screen_height, gs.Picture.RGBA8)
		self.screen_pic.ClearRGBA(1, 0, 1, 1)

		# Logos
		self.logo_mode = "FADEIN"
		self.logo_offset_phase = 0
		self.logo_picture_name = "logo_sys_zoetrope"
		self.logo_alpha = 0.0
		self.logo_display_timer = 0.0

		# Unlimited bob fx
		self.ubob_frame = 0
		self.ubob_buffer = gs.Picture(screen_size.WIDTH2, screen_size.HEIGHT2, gs.Picture.RGBA8)
		self.ubob_buffer.ClearRGBA(0, 0, 0, 0)
		self.ubob_offset_phase = 0

		# Font writer
		self.text_buffer = gs.Picture(screen_size.WIDTH3, screen_size.HEIGHT3, gs.Picture.RGBA8)
		self.text_buffer.ClearRGBA(0, 0, 0, 0)
		self.current_text_idx = 0
		self.text_drawn_on_top = True
		self.text_display_timer = 0.0
		self.text_pixel_w = 0.0

	def load_textures(self):
		self.pictures = {
							"bob_ball":None, "bob_torus":None, 
							"checkerboard_strip":None, "copper_list":None,
							"logo_mandarine":None, "logo_sys_zoetrope":None, 
							"font_sans_serif":None
						}

		for texture_name in self.pictures:
			texture_filename = os.path.join("res", texture_name + ".png")
			if os.path.exists(texture_filename):
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

						cb_pixel.x = min(1.0, cb_pixel.x * cb_luma + cl_pixel.x * (1.0 - cb_luma))
						cb_pixel.y = min(1.0, cb_pixel.y * cb_luma + cl_pixel.y * (1.0 - cb_luma))
						cb_pixel.z = min(1.0, cb_pixel.z * cb_luma + cl_pixel.z * (1.0 - cb_luma))

						cb_pixel.x = min(1.0, cb_pixel.x + max(0, (cl_pixel.x - screen_size.COLOUR_PURPLE.r) * cb_luma))
						cb_pixel.y = min(1.0, cb_pixel.y + max(0, (cl_pixel.y - screen_size.COLOUR_PURPLE.g) * cb_luma))
						cb_pixel.z = min(1.0, cb_pixel.z + max(0, (cl_pixel.z - screen_size.COLOUR_PURPLE.b) * cb_luma))

						cb_pixel.x = min(1.0, cb_pixel.x)
						cb_pixel.y = min(1.0, cb_pixel.y)
						cb_pixel.z = min(1.0, cb_pixel.z)								

						cb_pixel.w = 1.0
						self.pictures["checkerboard_strip"].PutPixelRGBA(x, int(y + strip_idx * (h / screen_size.ANIM_STRIPE)), cb_pixel.x, cb_pixel.y, cb_pixel.z, cb_pixel.w)

	def draw_pixel_art_logo(self):
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

		# Fade in using a blended rect
		if self.logo_alpha < 1.0:
			self.screen_pic.SetFillMode(gs.Picture.BrushSolid)
			self.screen_pic.SetPenMode(gs.Picture.PenNone)
			self.screen_pic.SetFillColorRGBA(screen_size.COLOUR_PURPLE.r, screen_size.COLOUR_PURPLE.g, screen_size.COLOUR_PURPLE.b, 1.0 - self.logo_alpha)
			src_rect.SetWidth(self.demo_screen_width)
			self.screen_pic.DrawRect(src_rect.sx, src_rect.sy, src_rect.ex, src_rect.ey)

		self.logo_offset_phase += 120.0 * self.dt

	def draw_checkerboard(self):
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

	def draw_unlimited_bobs(self, figure_mode = 0):
		x = 0
		y = 0

		bob_pic = self.pictures["bob_ball"]

		# Lissajous trajectory
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
		self.screen_pic.Blit(self.ubob_buffer, dest_rect, gs.iVector2(int(offset_x), screen_size.DISPL_HEIGHT1 + screen_size.DISPL_HEIGHT3 + 8))

		self.ubob_frame = (self.ubob_frame + 1)%screen_size.ANIM_STRIPE
		self.ubob_offset_phase += 120.0 * self.dt

		# print("clock = " + str(self.clock.GetDelta().to_sec()))

	def render_demo_text(self):
		if self.current_text_idx == -1 or self.text_display_timer > len(font_desc.demo_string[self.current_text_idx]) * 0.05:
			self.text_display_timer = 0.0
			self.current_text_idx += 1
			if self.current_text_idx >= len(font_desc.demo_string):
				self.current_text_idx = 0
			text_string = font_desc.demo_string[self.current_text_idx]

			print("text_str = " + text_string)
			self.text_pixel_w = self.font_writer_blit(self.pictures["font_sans_serif"], self.text_buffer, 0, 0, text_string)

		self.text_display_timer += self.dt

		dest_rect = self.text_buffer.GetRect()
		dest_rect.SetHeight(screen_size.DISPL_HEIGHT3)
		dest_rect_offset = dest_rect.Offset(0, screen_size.DISPL_HEIGHT1)
		dest_rect_offset.SetHeight(screen_size.DISPL_HEIGHT3 + 1)

		self.screen_pic.SetFillColorRGBA(screen_size.COLOUR_PURPLE_DARK.r, screen_size.COLOUR_PURPLE_DARK.g, screen_size.COLOUR_PURPLE_DARK.b, 1.0)
		self.screen_pic.SetFillMode(gs.Picture.BrushSolid)
		self.screen_pic.SetPenMode(gs.Picture.PenNone)
		self.screen_pic.DrawRect(dest_rect_offset.sx, dest_rect_offset.sy, dest_rect_offset.ex, dest_rect_offset.ey)
		self.screen_pic.Blit(self.text_buffer, dest_rect, gs.iVector2(0, screen_size.DISPL_HEIGHT1))

	def font_writer_blit(self, font_picture, dest_picture, x, y, text_string): ##(struct BitMap *font_BitMap, struct BitMap *font_BitMap_dark, struct BitMap *dest_BitMap, const char *glyph_array, const short *x_pos_array, short x, short y, UBYTE *text_string)

		def font_glyph_find_index(glyph, glyph_array):
			i = 0
			for g in glyph_array:
				if glyph == g:
					return i

				i += 1

			return -1

		i = 0

		cur_x = x
		y += screen_size.DISPL_HEIGHT1
		# glyph_h = font_BitMap->Rows;

		text_string = list(text_string)

		dest_picture.ClearRGBA(screen_size.COLOUR_PURPLE.r * 1.5, screen_size.COLOUR_PURPLE.g * 1.5, screen_size.COLOUR_PURPLE.b * 1.5, 1.0)

		while i < len(text_string):
			# /*	Space */
			if text_string[i] == ' ':
				cur_x += 4

			# /*	Write glyph */
			glyph_index = font_glyph_find_index(text_string[i], font_desc.tiny_font["glyph"])
			if glyph_index >= 0:
				glyph_w = font_desc.tiny_font["x_pos"][glyph_index + 1] - font_desc.tiny_font["x_pos"][glyph_index]
				dest_rect = font_picture.GetRect()
				dest_rect.SetWidth(glyph_w)
				dest_rect = dest_rect.Offset(cur_x, 1)
				src_matrix = gs.Matrix3.TranslationMatrix(gs.Vector2(font_desc.tiny_font["x_pos"][glyph_index] - cur_x, -1))
				dest_picture.BlitTransform(font_picture, dest_rect, src_matrix, gs.Picture.Nearest)

				cur_x += glyph_w	

			i += 1

		return cur_x - x

