require ('app/scripts/luaclass')
local screen_size = require('app/scripts/screen_size')
local font_desc = require('app/scripts/font_desc')
require('app/scripts/utils')

return Class {

  __init__ = function(self, demo_screen_width, demo_screen_height)
    self.dt = 1.0/60.0
    self.demo_screen_width = demo_screen_width
    self.demo_screen_height = demo_screen_height
    self.pictures = nil
    self.screen_tex = nil
    self.ubob_phase_x = 0
    self.ubob_phase_y = 0
    self.ubob_scale = 0
    self.frame = 0
    self.figure_mode = 0
    self.palette_idx = 0
    self.x_margin = math.floor((self.demo_screen_width-screen_size.DISPL_WIDTH2)/2.0)
    self.screen_pic = hg.Picture(demo_screen_width, demo_screen_height, hg.PictureRGBA8)
    self.screen_pic:ClearRGBA(1, 0, 1, 1)
    self.logo_mode = 'FADEIN'
    self.logo_offset_phase = 0
    self.logo_picture_name = 'logo_sys_zoetrope'
    self.logo_alpha = 0.0
    self.logo_display_timer = 0.0
    self.ubob_frame = 0
    self.ubob_buffer = hg.Picture(screen_size.WIDTH2, screen_size.HEIGHT2, hg.PictureRGBA8)
    self.ubob_buffer:ClearRGBA(0, 0, 0, 0)
    self.ubob_offset_phase = 0
    self.clear_line_y = 0
    self.text_buffer = hg.Picture(screen_size.WIDTH3, screen_size.HEIGHT3, hg.PictureRGBA8)
    self.text_buffer:ClearRGBA(0, 0, 0, 0)
    self.current_text_idx = 0
    self.text_drawn_on_top = true
    self.text_display_timer = 0.0
    self.text_pixel_w = 0.0
  end,

  print_ascii_intro = function(self)
    for _, l in ipairs(font_desc.ascii_art) do
      print(l)
    end
  end,

  update_dt = function(self, dt)
    dt = dt or 1.0/60.0
    self.dt = dt
  end,

  load_textures = function(self)
    self.pictures = { bob_ball=0, bob_torus=0, bob_ball_pal0=0, bob_torus_pal0=0, bob_ball_pal1=0, bob_torus_pal1=0, bob_ball_pal2=0, bob_torus_pal2=0, bob_ball_pal3=0, bob_torus_pal3=0, checkerboard_strip=0, copper_list=0, logo_mandarine=0, logo_sys_zoetrope=0, font_sans_serif=0 }
    for texture_name, texture_value in pairs(self.pictures) do
      local texture_filename = 'res/' .. texture_name .. '.png' -- PYLUA.join(os.path, 'res', texture_name+'.png')
      -- if os.path.exists(texture_filename) then
        self.pictures[texture_name] = hg.Picture()
        hg.LoadPicture(self.pictures[texture_name], texture_filename)
      -- end
    end
    if self.pictures['checkerboard_strip'] then
      -- local pixel_data = self.pictures['checkerboard_strip']:GetData()
      local w = self.pictures['checkerboard_strip']:GetWidth()
      local h = self.pictures['checkerboard_strip']:GetHeight()
      for strip_idx = 0, screen_size.ANIM_STRIPE do
        for y  = 0, math.floor(h/screen_size.ANIM_STRIPE) do
          local cl_pixel = self.pictures['copper_list']:GetPixelRGBA(8, y+screen_size.DISPL_HEIGHT2-screen_size.CHECKERBOARD_HEIGHT+21-16)
          for x = 0, w do
            local cb_pixel = self.pictures['checkerboard_strip']:GetPixelRGBA(x, math.floor(y+strip_idx*h/screen_size.ANIM_STRIPE))
            local cb_luma = math.sqrt(cb_pixel.x)*0.3+math.max(0, cl_pixel.x-0.25)
            cb_pixel.x = math.min(1.0, cb_pixel.x*cb_luma+cl_pixel.x*(1.0-cb_luma))
            cb_pixel.y = math.min(1.0, cb_pixel.y*cb_luma+cl_pixel.y*(1.0-cb_luma))
            cb_pixel.z = math.min(1.0, cb_pixel.z*cb_luma+cl_pixel.z*(1.0-cb_luma))
            cb_pixel.x = math.min(1.0, cb_pixel.x+math.max(0, (cl_pixel.x-screen_size.COLOUR_PURPLE.r)*cb_luma))
            cb_pixel.y = math.min(1.0, cb_pixel.y+math.max(0, (cl_pixel.y-screen_size.COLOUR_PURPLE.g)*cb_luma))
            cb_pixel.z = math.min(1.0, cb_pixel.z+math.max(0, (cl_pixel.z-screen_size.COLOUR_PURPLE.b)*cb_luma))
            cb_pixel.x = math.min(1.0, cb_pixel.x)
            cb_pixel.y = math.min(1.0, cb_pixel.y)
            cb_pixel.z = math.min(1.0, cb_pixel.z)
            cb_pixel.w = 1.0
            self.pictures['checkerboard_strip']:PutPixelRGBA(x, math.floor(y+strip_idx*h/screen_size.ANIM_STRIPE), cb_pixel.x, cb_pixel.y, cb_pixel.z, cb_pixel.w)
          end
        end
      end
    end
  end,

  clear_screen = function(self)
    self.screen_pic:ClearRGBA(screen_size.COLOUR_PURPLE.r, screen_size.COLOUR_PURPLE.g, screen_size.COLOUR_PURPLE.b, 1.0)
  end,

  draw_pixel_art_logo = function(self)
    local fade_speed = 4.0
    if self.logo_mode=='FADEIN' then
      self.logo_alpha = self.logo_alpha+self.dt*fade_speed
      if self.logo_alpha>1.0 then
        self.logo_alpha = 1.0
        self.logo_display_timer = 0.0
        self.logo_mode = 'DISPLAY_LOGO'
      end
    end

    if self.logo_mode=='DISPLAY_LOGO' then
      self.logo_display_timer = self.logo_display_timer+self.dt*10.0
      if self.logo_display_timer>100.0 then
        self.logo_alpha = 1.0
        self.logo_mode = 'FADEOUT'
      end
    end

    if self.logo_mode=='FADEOUT' then
      self.logo_alpha = self.logo_alpha-self.dt*fade_speed
      if self.logo_alpha<0.0 then
        self.logo_alpha = 0.0
        self.logo_mode = 'CHANGE_LOGO'
      end
    end

    if self.logo_mode=='CHANGE_LOGO' then
      if self.logo_picture_name=='logo_sys_zoetrope' then
        self.logo_picture_name = 'logo_mandarine'
      else
        self.logo_picture_name = 'logo_sys_zoetrope'
      end
      self.logo_mode = 'FADEIN'
    end

    local logo_pic = self.pictures[self.logo_picture_name]
    local src_rect = logo_pic:GetRect()
    local offset_x, offset_y, x_margin
    if self.logo_picture_name=='logo_sys_zoetrope' then
      x_margin = (self.demo_screen_width-src_rect:GetWidth())/2.0
      offset_x = (math.sin(math.rad(self.logo_offset_phase))+1.0)*x_margin
    else
      x_margin = 32.0
      offset_x = math.sin(math.rad(self.logo_offset_phase))*x_margin
    end

    offset_y = 0

    self.screen_pic:Blit(logo_pic, src_rect, hg.IntVector2(math.floor(offset_x), math.floor(offset_y)))
    if self.logo_alpha<1.0 then
      self.screen_pic:SetFillMode(hg.BrushSolid)
      self.screen_pic:SetPenMode(hg.PenNone)
      self.screen_pic:SetFillColorRGBA(screen_size.COLOUR_PURPLE.r, screen_size.COLOUR_PURPLE.g, screen_size.COLOUR_PURPLE.b, Quantize(1.0-self.logo_alpha, 8))
      src_rect:SetWidth(self.demo_screen_width)
      self.screen_pic:DrawRect(src_rect.sx, src_rect.sy, src_rect.ex, src_rect.ey)
    end
    self.logo_offset_phase = self.logo_offset_phase+120.0*self.dt
  end,

  draw_checkerboard = function(self)
    local copper_pic = self.pictures['copper_list']
    local offset_y = screen_size.DISPL_HEIGHT1+screen_size.DISPL_HEIGHT3
    local source_rect = copper_pic:GetRect()
    for i =0, math.floor(self.demo_screen_width/source_rect:GetWidth()) do
      self.screen_pic:Blit(copper_pic, source_rect, hg.IntVector2(i*source_rect:GetWidth(), offset_y))
    end
    local checker_pic = self.pictures['checkerboard_strip']
    local dest_rect = checker_pic:GetRect()
    dest_rect:SetHeight(screen_size.CHECKERBOARD_HEIGHT)
    dest_rect = dest_rect:Offset(self.x_margin, screen_size.DISPL_HEIGHT2+screen_size.DISPL_HEIGHT3-16)
    local src_matrix = hg.Matrix3.TranslationMatrix(hg.Vector2(-self.x_margin, (math.floor(self.frame)%screen_size.ANIM_STRIPE)*screen_size.CHECKERBOARD_HEIGHT-dest_rect.sy))
    self.screen_pic:BlitTransform(checker_pic, dest_rect, src_matrix, hg.FilterNearest)
    self.frame = self.frame+30.0*self.dt
  end,

  set_next_unlimited_bobs = function(self)
    self.figure_mode = self.figure_mode+1
    if self.figure_mode>5 then
      self.figure_mode = 0
    end
    self.palette_idx = self.palette_idx+1
    if self.palette_idx>3 then
      self.palette_idx = 0
    end
    self.ubob_phase_x = 0
    self.ubob_phase_y = 0
    self.clear_line_y = 0
    self.ubob_scale = 0
  end,

  draw_unlimited_bobs = function(self)
    local x = 0
    local y = 0

    table_to_angle = function(table_index)
      return 180*table_index/3
    end

    has_ended = function()
      if self.ubob_phase_x<360*4 or self.ubob_phase_y<360*4 then
        return false
      end
      return true
    end
    local bob_pic_name
    if self.figure_mode==0 then
      self.ubob_phase_x = self.ubob_phase_x+table_to_angle(3)*self.dt
      self.ubob_phase_y = self.ubob_phase_y+table_to_angle(2)*self.dt
      bob_pic_name = 'bob_ball'
    elseif self.figure_mode==1 then
      self.ubob_phase_x = self.ubob_phase_x+table_to_angle(2)*self.dt
      self.ubob_phase_y = self.ubob_phase_y+table_to_angle(3)*self.dt
      bob_pic_name = 'bob_torus'
    elseif self.figure_mode==2 then
      self.ubob_phase_x = self.ubob_phase_x+table_to_angle(3)*self.dt
      self.ubob_phase_y = self.ubob_phase_y+table_to_angle(1)*self.dt
      bob_pic_name = 'bob_ball'
    elseif self.figure_mode==3 then
      self.ubob_phase_x = self.ubob_phase_x+table_to_angle(1)*self.dt
      self.ubob_phase_y = self.ubob_phase_y+table_to_angle(5)*self.dt
      bob_pic_name = 'bob_torus'
    elseif self.figure_mode==4 then
      self.ubob_phase_x = self.ubob_phase_x+table_to_angle(1)*self.dt
      self.ubob_phase_y = self.ubob_phase_y+table_to_angle(2)*self.dt
      bob_pic_name = 'bob_ball'
    elseif self.figure_mode==5 then
      self.ubob_phase_x = self.ubob_phase_x+table_to_angle(1)*self.dt
      self.ubob_phase_y = self.ubob_phase_y+table_to_angle(1)*self.dt
      bob_pic_name = 'bob_ball'
    end
    local phase_scaler = 0.5
    local bob_pic = self.pictures[bob_pic_name .. '_pal' .. tostring(self.palette_idx)]
    x = (screen_size.DISPL_WIDTH2b-screen_size.DISPL_WIDTH2b*0.8+bob_pic:GetRect():GetWidth())*0.5+(math.cos(math.rad(self.ubob_phase_x)*phase_scaler)+1.0*0.5)*(screen_size.DISPL_WIDTH2b-self.ubob_scale)*0.5*0.8
    y = (math.sin(math.rad(self.ubob_phase_y)*phase_scaler)+1.0*0.5)*(screen_size.DISPL_HEIGHT2b-self.ubob_scale)*0.5*0.75
    x = x+bob_pic:GetRect():GetWidth()
    y = y+bob_pic:GetRect():GetWidth()
    y = y+self.ubob_frame*screen_size.DISPL_HEIGHT2
    x = math.floor(x)
    y = math.floor(y)
    local offset_x = math.sin(math.rad(self.ubob_offset_phase))*32.0+self.x_margin
    if  not has_ended() then
      if bob_pic_name['bob_ball'] ~= nil then
        local dest_rect = bob_pic:GetRect()
        self.ubob_buffer:Blit(bob_pic, dest_rect, hg.IntVector2(x, y))
      elseif bob_pic_name['bob_torus'] ~= nil then
        dest_rect = bob_pic:GetRect()
        dest_rect:SetHeight(dest_rect:GetWidth())
        local _bob_frame = math.floor((math.floor(self.ubob_offset_phase/10)%8))
        dest_rect = dest_rect:Offset(0, _bob_frame*dest_rect:GetWidth())
        self.ubob_buffer:Blit(bob_pic, dest_rect, hg.IntVector2(x, y))
      end
    end
    dest_rect = self.ubob_buffer:GetRect()
    dest_rect:SetHeight(screen_size.DISPL_HEIGHT2)
    dest_rect = dest_rect:Offset(0, self.ubob_frame*screen_size.DISPL_HEIGHT2)
    self.screen_pic:Blit(self.ubob_buffer, dest_rect, hg.IntVector2(math.floor(offset_x), screen_size.DISPL_HEIGHT1+screen_size.DISPL_HEIGHT3+8))
    self.ubob_frame = (self.ubob_frame+1%screen_size.ANIM_STRIPEb)
    self.ubob_offset_phase = self.ubob_offset_phase+120.0*self.dt
    self.ubob_scale = self.ubob_scale+self.dt*1.5
    return not has_ended()
  end,

  clear_playfield = function(self, from_top)
    from_top = from_top or true
    local offset_x = math.sin(math.rad(self.ubob_offset_phase))*32.0+self.x_margin
    for s = 0, screen_size.ANIM_STRIPEb do
      if from_top then
        local _y = self.clear_line_y+s*screen_size.DISPL_HEIGHT2b
        for _x = 0, math.floor(screen_size.WIDTH2b/2) do
          self.ubob_buffer:PutPixelRGBA(_x*2, _y+7, 0, 0, 0, 0)
          self.ubob_buffer:PutPixelRGBA(_x*2, _y+2, 0, 0, 0, 0)
          self.ubob_buffer:PutPixelRGBA(_x*2+1, _y+1, 0, 0, 0, 0)
          self.ubob_buffer:PutPixelRGBA(_x*2, _y, 0, 0, 0, 0)
          self.ubob_buffer:PutPixelRGBA(_x*2+1, _y, 0, 0, 0, 0)
        end
      else
        _y = screen_size.DISPL_HEIGHT2b-self.clear_line_y+s*screen_size.DISPL_HEIGHT2b
        for _x = 0, math.floor(screen_size.WIDTH2b/2) do
          self.ubob_buffer:PutPixelRGBA(_x*2, _y-5, 0, 0, 0, 0)
          self.ubob_buffer:PutPixelRGBA(_x*2, _y, 0, 0, 0, 0)
          self.ubob_buffer:PutPixelRGBA(_x*2+1, _y+1, 0, 0, 0, 0)
          self.ubob_buffer:PutPixelRGBA(_x*2, _y+2, 0, 0, 0, 0)
          self.ubob_buffer:PutPixelRGBA(_x*2+1, _y+2, 0, 0, 0, 0)
        end
      end
    end
    local dest_rect = self.ubob_buffer:GetRect()
    dest_rect:SetHeight(screen_size.DISPL_HEIGHT2)
    dest_rect = dest_rect:Offset(0, self.ubob_frame*screen_size.DISPL_HEIGHT2)
    self.screen_pic:Blit(self.ubob_buffer, dest_rect, hg.IntVector2(math.floor(offset_x), screen_size.DISPL_HEIGHT1+screen_size.DISPL_HEIGHT3+8))
    self.ubob_frame = (self.ubob_frame+1%screen_size.ANIM_STRIPEb)
    self.ubob_offset_phase = self.ubob_offset_phase+120.0*self.dt
    self.clear_line_y = self.clear_line_y+2
    if self.clear_line_y>screen_size.DISPL_HEIGHT2 then
      self.ubob_buffer:ClearRGBA(0, 0, 0, 0)
      return true
    else
      return false
    end
  end,

  render_demo_text = function(self)
    -- local text_duration = #(font_desc.demo_string[self.current_text_idx + 1])*0.05
    -- local fade_duration = 0.2
    -- if self.current_text_idx==-1 or self.text_display_timer>text_duration then
    --   self.text_display_timer = 0.0
    --   self.current_text_idx = self.current_text_idx+1
    --   if self.current_text_idx>=#font_desc.demo_string then
    --     self.current_text_idx = 0
    --   end
    --   local text_string = font_desc.demo_string[self.current_text_idx]
    --   self.text_pixel_w = self:font_writer_blit(self.pictures['font_sans_serif'], self.text_buffer, 0, 0, text_string)
    -- end
    -- self.text_display_timer = self.text_display_timer+self.dt*0.5
    -- local opacity
    -- if self.text_display_timer<fade_duration then
    --   opacity = Clamp(RangeAdjust(self.text_display_timer, 0.0, fade_duration, 0.0, 1.0), 0.0, 1.0)
    -- elseif self.text_display_timer>text_duration-fade_duration then
    --   opacity = Clamp(RangeAdjust(self.text_display_timer, text_duration-fade_duration, text_duration, 1.0, 0.0), 0.0, 1.0)
    -- else
    --   opacity = 1.0
    -- end
    -- opacity = Quantize(opacity, 8)
    -- local dest_rect = self.text_buffer:GetRect()
    -- dest_rect:SetHeight(screen_size.DISPL_HEIGHT3)
    -- local dest_rect_offset = dest_rect:Offset(0, screen_size.DISPL_HEIGHT1)
    -- dest_rect_offset:SetHeight(screen_size.DISPL_HEIGHT3+1)
    -- self.screen_pic:SetFillColorRGBA(screen_size.COLOUR_PURPLE.r*1.5, screen_size.COLOUR_PURPLE.g*1.5, screen_size.COLOUR_PURPLE.b*1.5, 1.0)
    -- self.screen_pic:SetFillMode(hg.BrushSolid)
    -- self.screen_pic:SetPenMode(hg.PenNone)
    -- self.screen_pic:DrawRect(dest_rect_offset.sx, dest_rect_offset.sy, dest_rect_offset.ex, dest_rect_offset.ey)
    -- self.screen_pic:Blit(self.text_buffer, dest_rect, hg.IntVector2(math.floor((screen_size.WIDTH3-self.text_pixel_w)/2.0), screen_size.DISPL_HEIGHT1+1))
    -- if opacity<1.0 then
    --   self.screen_pic:SetFillColorRGBA(screen_size.COLOUR_PURPLE.r*1.5, screen_size.COLOUR_PURPLE.g*1.5, screen_size.COLOUR_PURPLE.b*1.5, 1.0-opacity)
    --   self.screen_pic:DrawRect(dest_rect_offset.sx, dest_rect_offset.sy, dest_rect_offset.ex, dest_rect_offset.ey)
    -- end
  end,

  font_writer_blit = function(self, font_picture, dest_picture, x, y, text_string)

    font_glyph_find_index = function(glyph, glyph_array)
      local i = 0
      for _, g in ipairs(glyph_array) do
        if glyph==g then
          return i
        end
        i = i+1
      end
      return -1
    end
    local i = 0
    local cur_x = x
    y = y + screen_size.DISPL_HEIGHT1
    local text_string = stringToList(text_string)
    dest_picture.ClearRGBA(screen_size.COLOUR_PURPLE.r*1.5, screen_size.COLOUR_PURPLE.g*1.5, screen_size.COLOUR_PURPLE.b*1.5, 1.0)
    while i<#text_string do
      if text_string[i + 1] == ' ' then
        cur_x = cur_x+4
      end
      local glyph_index = font_glyph_find_index(text_string[i], font_desc.tiny_font['glyph'])
      if glyph_index>=0 then
        local glyph_w = font_desc.tiny_font['x_pos'][glyph_index+1]-font_desc.tiny_font['x_pos'][glyph_index]
        local dest_rect = font_picture:GetRect()
        dest_rect:SetWidth(glyph_w)
        dest_rect = dest_rect:Offset(cur_x, 1)
        local src_matrix = hg.Matrix3.TranslationMatrix(hg.Vector2(font_desc.tiny_font['x_pos'][glyph_index]-cur_x, -1))
        dest_picture.BlitTransform(font_picture, dest_rect, src_matrix, hg.FilterNearest)
        cur_x = cur_x+glyph_w
      end
      i = i + 1
    end
    return cur_x-x
  end
}

