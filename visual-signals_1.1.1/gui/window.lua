local gui = require("__flib__.gui-beta")

local function create_window(player, display_guis)
    -- create a new GUI window for a player
    local gui_id = "vs-gui-" .. player.index .. "-" .. game.tick
    local gui_result = gui.build(player.gui.screen, {
        {
            type = "frame",
            direction = "vertical",
            ref = {"window"},
            children = {
                {
                    type = "flow", ref = {"titlebar"},
                    children = {
                        {
                            type = "label",
                            style = "frame_title",
                            caption = { "visual-signals.window-title" },
                            ignored_by_interaction = true
                        },
                        {
                            type = "empty-widget",
                            style = "flib_titlebar_drag_handle",
                            ignored_by_interaction = true
                        },
                        {
                            type = "sprite-button",
                            style = "frame_action_button",
                            sprite = "utility/add",
                            actions = {
                                on_click = { gui_id = gui_id, type = "gui", action = "add" }
                            }
                        }
                    }
                },
                {
                    type = "flow", direction = "vertical",
                    children = display_guis
                }
            }
        }
    })
    gui_result.titlebar.drag_target = gui_result.window
    global.guis[gui_id] = { player = player, gui = gui_result }
end

local function destroy(gui_id)
    local player_gui = global.guis[gui_id]
    player_gui.gui.window.destroy()
    global.guis[gui_id] = nil
end

return {
    create_window = create_window,
    destroy = destroy
}
