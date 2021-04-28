local events = require("__flib__.event")
local gui = require("__flib__.gui-beta")
local toolbar = require("gui/toolbar")
local events_table = require("gui/events_table")

local function handle_action(action)
    if action.action == "close-window" then
        local train_log_gui = global.guis[action.gui_id]
        train_log_gui.gui.window.destroy()
        global.guis[action.gui_id] = nil
    end
end

local function header(gui_id)
    return {
        type = "flow",
        ref = {"titlebar"},
        children = {
            {type = "label", style = "frame_title", caption = {"train-log.header"}, ignored_by_interaction = true},
            {type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true},
            {
                type = "button",
                caption = "x",
                style = "frame_action_button",
                actions = {
                    on_click = { type = "generic", action = "close-window", gui_id = gui_id },
                }
            }
        }
    }
end

local function open_gui(player)
    local gui_id = "gui-" .. player.index .. "-" .. game.tick
    local gui_contents = {
        {
            type = "frame",
            direction = "vertical",
            ref = { "window" },
            children = {
                header(gui_id),
                toolbar.create_toolbar(gui_id),
                {
                    type = "flow", direction = "vertical", ref = { "internal" }
                },
            }
        }
    }
    local train_log_gui = gui.build(player.gui.screen, gui_contents)
    global.guis[gui_id] = {
        gui_id = gui_id,
        gui = train_log_gui,
        player = player
    }
    train_log_gui.titlebar.drag_target = train_log_gui.window
    train_log_gui.window.force_auto_center()

    events_table.create_events_table(gui_id)
end

gui.hook_events(function(event)
	local action = gui.read_action(event)
	if action then
        if action.type == "generic" then
            handle_action(action, event)
        elseif action.type == "table" then
            events_table.handle_action(action, event)
        elseif action.type == "toolbar" then
            toolbar.handle_action(action, event)
        end
	end
end)

return {
    open = open_gui
}