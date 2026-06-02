return spectrum.Input.Controls({
      -- stylua: ignore
      controls = {
            -- Controls can be mapped to keys, text, gamepad buttons, joystick axes, or mouse presses.
            -- Prefix the control with the type, e.g. "axis:lefty-", "mouse:1", "button:rightshoulder", "text:>".
            -- If no prefix is given, the control is assumed to be a key.
            -- Controls can also be combinations of inputs, e.g. "lshift a" or "lctrl s".
            -- See the LÖVE wiki for all of the constants.
            move_upleft    = { "q", "y", "axis:leftx- axis:lefty-" },
            move_up        = { "w", "k", "axis:lefty-", "button:dpup"    },
            move_upright   = { "e", "u", "axis:leftx+ axis:lefty-"       },
            move_left      = { "a", "h", "axis:leftx-", "button:dpleft"  },
            move_right     = { "d", "l", "axis:leftx+", "button:dpright" },
            move_downleft  = { "z", "b", "axis:leftx- axis:lefty+"       },
            move_down      = { "s", "j", "axis:lefty+", "button:dpdown"  },
            move_downright = { "c", "n", "axis:leftx+ axis:lefty+"       },
            wait           = { "x",      "button:a"            },
            restart        = { "r",      "button:back", "button:guide" },
            quit           = { "q",      "button:start"        },
            play           = { "p",      "button:a"            },
            load           = { "l",      "button:y"            },
            inventory      = { "i",      "button:x"            },
            back           = { "escape", "button:b"            },
            pickup         = { "g",      "button:rightshoulder" },
            select         = { "return", "button:a"            },
            tab            = { "tab",    "button:leftshoulder" },
      },
      -- Pairs are controls that map to either 4 or 8 directions.
      -- With only 4 directions, the order is up, left, right, down.
      pairs = {
            -- stylua: ignore
            move = {
                  "move_upleft", "move_up",   "move_upright",
                  "move_left",               "move_right",
                  "move_downleft", "move_down", "move_downright",
            },
      },
})
