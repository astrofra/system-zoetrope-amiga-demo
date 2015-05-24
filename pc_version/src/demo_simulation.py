import os
import gs
import screen_size

class demoSimulation:
	def __init__(self):
		self.textures = None
		self.screen_tex = None

	def loadTextures(self):
		self.textures = {"bob_ball":None, "bob_torus":None, "checkerboard_strip":None, "logo_mandarine":None, "logo_sys_zoetrope":None, "font_sans_serif":None}
		for texture_name in self.textures:
			texture_filename = os.path.join("res", texture_name + ".png")
			if (os.path.exists(texture_filename)):
				self.textures[texture_name] = gs.LoadPicture(texture_filename)
				print("Found texture : ", texture_filename)

	def drawMandarineLogo(self, logo_pic_name, dest_pic, offset_x = 0, offset_y = 0):
		logo_pic = self.textures[logo_pic_name]
		dest_pic.Blit(logo_pic, logo_pic.GetRect().Offset(offset_x, offset_y), gs.Matrix3.TranslationMatrix(gs.Vector3(-offset_x, -offset_y, 0)), False)

	def drawCheckerboard(self, dest_pic, frame = 0):
		checker_pic = self.textures["checkerboard_strip"]
		offset_y = (frame%screen_size.ANIM_STRIPE) * 100 + screen_size.DISPL_HEIGHT2
		dest_rect = checker_pic.GetRect()
		dest_rect.SetHeight(100)
		dest_rect = dest_rect.Offset(0, offset_y)
		dest_pic.Blit(checker_pic, dest_rect, gs.Matrix3.TranslationMatrix(gs.Vector3(0, -offset_y, 0)), False)

	def drawUnlimitedBobs(self, dest_pic, figure_mode = 0):
		x = 0
		y = 0
		y += screen_size.DISPL_HEIGHT1
		bob_pic = self.textures["bob_ball"]
		dest_rect = bob_pic.GetRect()
		dest_rect = dest_rect.Offset(x, y)
		dest_pic.Blit(bob_pic, dest_rect, gs.Matrix3.TranslationMatrix(gs.Vector3(-x, -y, 0)), False)