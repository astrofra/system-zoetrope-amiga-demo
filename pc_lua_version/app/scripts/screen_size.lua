local DEFAULT_DISP_WIDTH = 320
local DISPL_WIDTH2 = DEFAULT_DISP_WIDTH
local DISPL_HEIGHT2 = 150
local DISPL_HEIGHT2b = 150
local DISPL_HEIGHT3 = 13
local ANIM_STRIPE = 10
local  ANIM_STRIPEb = 8

return {
    DEFAULT_DISP_WIDTH = DEFAULT_DISP_WIDTH,
    WIDTH1 = math.floor(720/2),
    HEIGHT1 = 160,
    DISPL_WIDTH1 = DEFAULT_DISP_WIDTH,
    DISPL_HEIGHT1 = 79,
    ANIM_STRIPE = ANIM_STRIPE,
    WIDTH2 = 320,
    DISPL_WIDTH2 = DEFAULT_DISP_WIDTH,
    DISPL_HEIGHT2 = DISPL_HEIGHT2,
    HEIGHT2 = DISPL_HEIGHT2*ANIM_STRIPE,
    CHECKERBOARD_HEIGHT = 100,
    ANIM_STRIPEb = ANIM_STRIPEb,
    WIDTH2b = math.floor(720/2),
    DISPL_WIDTH2b = DEFAULT_DISP_WIDTH,
    DISPL_HEIGHT2b = DISPL_HEIGHT2b,
    HEIGHT2b = DISPL_HEIGHT2b*ANIM_STRIPEb,
    WIDTH3 = math.floor(720/2),
    DISPL_HEIGHT3 = DISPL_HEIGHT3,
    HEIGHT3 = DISPL_HEIGHT3 * 2,
    COLOUR_PURPLE_DARK = hg.Color(42/255.0, 18/255.0, 33/255.0, 1.0),
    COLOUR_PURPLE = hg.Color(74/255.0, 34/255.0, 81/255.0, 1.0),
    COLOUR_PURPLE_LIGHT = hg.Color(95/255.0, 0/255.0, 75/255.0, 1.0),
}