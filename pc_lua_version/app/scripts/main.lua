hg = require('harfang')
-- local pymsgbox = require('pymsgbox')
-- local sys = require('sys')
-- local dirname = require('os.path').dirname
-- local realpath = require('os.path').realpath
require('app/scripts/utils')
local DemoSimulation = require('app/scripts/demo_simulation')

main = function()
  local pc_screen_windowed = true
  local pc_screen_width = 1280
  local pc_screen_height = 720

  local plus = hg.GetPlus()
  plus:CreateWorkers()

  pc_screen_windowed = false

  local screen_resolutions = {'640x480', '720x568', '800x600', '1280x800'}
  pc_screen_width = 800
  pc_screen_height = 600
  local demo_screen_width = math.floor(720/2)
  local demo_screen_height = math.floor(568/2)
  local amiga_screen_ratio = demo_screen_height/demo_screen_width
  local overscan_factor = hg.Vector4(16/demo_screen_width, 4/demo_screen_height, (demo_screen_width-16)/demo_screen_width, (demo_screen_height-28)/demo_screen_height)

  if pc_screen_windowed then
    pc_screen_width = int(pc_screen_height*demo_screen_width/demo_screen_height)
  end

  hg.LoadPlugins()
  -- hg.MountFileDriver(hg.StdFileDriver())
  hg.MountFileDriver(hg.StdFileDriver('app/res/'), 'res/')


  if pc_screen_windowed then
    local w_mode = hg.Window.Windowed
  else
    w_mode = hg.Window.Fullscreen
  end

  plus:RenderInit(pc_screen_width, pc_screen_height) -- , 1, w_mode)
  plus:AudioInit()
  local egl = plus:GetRendererAsync()
  local font = hg.RasterFont('@core/fonts/default.ttf', 48, 512)

  local demo = DemoSimulation(demo_screen_width, demo_screen_height)

  demo:print_ascii_intro()

  demo:load_textures()
  local demo_screen_tex = egl:NewTexture('demo_screen_texture')

  local res = egl:CreateTexture(demo_screen_tex, demo.screen_pic)
  print('CreateTexture() returned ', res)
  local al = plus:GetMixerAsync()
  al:Open()
  local channel_state = hg.MixerChannelState(0, 1, hg.MixerRepeat)
  al:Stream('res/music_loop.ogg', channel_state)
  local mode_switch = 'DMODE_SW_UBOB'

  while not plus:IsAppEnded() do

    local dt = plus:UpdateClock()
    plus:Clear()
    demo:update_dt(hg.time_to_sec_f(dt))
    demo:clear_screen()
    demo:draw_pixel_art_logo()
    demo:draw_checkerboard()

    if mode_switch == 'DMODE_SW_UBOB' then
      if  not demo:draw_unlimited_bobs() then
        if (demo.figure_mode%2) == 0 then
          mode_switch = 'DMODE_SW_CLEAR_FROM_TOP'
        else
          mode_switch = 'DMODE_SW_CLEAR_FROM_BOTTOM'
        end
      end
    elseif mode_switch == 'DMODE_SW_CLEAR_FROM_TOP' then
      if demo:clear_playfield(true) then
        mode_switch = 'DMODE_SW_NEXT_UBOB'
      end
    elseif mode_switch == 'DMODE_SW_CLEAR_FROM_BOTTOM' then
      if demo:clear_playfield(false) then
        mode_switch = 'DMODE_SW_NEXT_UBOB'
      end
    elseif mode_switch == 'DMODE_SW_NEXT_UBOB' then
      demo:set_next_unlimited_bobs()
      mode_switch = 'DMODE_SW_UBOB'
    end

    demo:render_demo_text()

    egl:BlitTexture(demo_screen_tex, hg.BinaryData(demo.screen_pic:GetData()), demo_screen_width, demo_screen_height)

    if pc_screen_windowed then
      plus:Quad2D(0, 0, 0, pc_screen_height, pc_screen_width, pc_screen_height, pc_screen_width, 0, hg.Color.White, hg.Color.White, hg.Color.White, hg.Color.White, demo_screen_tex, overscan_factor.x, overscan_factor.y, overscan_factor.z, overscan_factor.w)
    else
      local _x_offset = (pc_screen_width-pc_screen_width*amiga_screen_ratio)*0.5
      plus:Quad2D(_x_offset, 0, _x_offset, pc_screen_height, _x_offset+pc_screen_width*amiga_screen_ratio, pc_screen_height, _x_offset+pc_screen_width*amiga_screen_ratio, 0, hg.Color.White, hg.Color.White, hg.Color.White, hg.Color.White, demo_screen_tex, overscan_factor.x, overscan_factor.y, overscan_factor.z, overscan_factor.w)
    end

    plus:Flip()
  end
end

print("Demo ended, bye bye!")

main()
