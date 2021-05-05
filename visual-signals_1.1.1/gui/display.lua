local gui = require("__flib__.gui-beta")

local function find_prototype(type, name)
    if type == "item" then
        prototype = game.item_prototypes[name]
    elseif type == "fluid" then
        prototype = game.fluid_prototypes[name]
    elseif type == "virtual-signal" then
        prototype = game.virtual_signal_prototypes[name]
    end
    return prototype
end

local function update_slot_table(slot_table, circuit_network, i, delete)
    local children = slot_table.children
    if not circuit_network then
        if delete then
            local size = table_size(children)
            for j = i + 1, size do
                children[j].destroy()
            end
        end
        return i
    end
    if circuit_network and circuit_network.valid then
        local style = "flib_slot_button_default"
        if circuit_network.wire_type == defines.wire_type.green then
            style = "flib_slot_button_green"
        elseif circuit_network.wire_type == defines.wire_type.red then
            style = "flib_slot_button_red"
        end

        for _, v in pairs(circuit_network.signals) do
            i = i + 1
            local type = v.signal.type
            local name = v.signal.name
            local prototype = find_prototype(type, name)
            local child = children[i]
            if child then
                child.style = style
                child.sprite = type .. "/" .. name
                child.number = v.count
                child.tooltip = prototype.localised_name
            else
                slot_table.add {
                    type = "sprite-button",
                    style = style,
                    sprite = type .. "/" .. name,
                    number = v.count,
                    tooltip = prototype.localised_name
                }
            end
        end
    end
    return i
end

local function update(visual_signal_key, visual_signal_gui)
    local slot_table = visual_signal_gui.slot_table
    local visual_signal_entry = global.visual_signals[visual_signal_key]

    local label = visual_signal_gui.label
    if label then
        label.caption = visual_signal_entry.title
    end

    local entity = visual_signal_entry.entity
    if not entity.valid then
        return false
    end
    local circuit_red = entity.get_circuit_network(defines.wire_type.red)
    local circuit_green = entity.get_circuit_network(defines.wire_type.green)
    local i = update_slot_table(slot_table, circuit_red, 0)
    i = update_slot_table(slot_table, circuit_green, i)
    update_slot_table(slot_table, nil, i, true)
    return true
end

local function for_display(visual_signal_key)
    -- create GUI for an existing visual signal entity
    local visual_signal_entry = global.visual_signals[visual_signal_key]
    return {
        type = "flow",
        direction = "vertical",
        ref = { "displays", visual_signal_key, "flow" },
        children = {
            {
                type = "label",
                ref = { "displays", visual_signal_key, "label" },
                caption = visual_signal_entry.title
            },
            {
                type = "frame",
                style = "slot_button_deep_frame",
                children = {
                    {
                        type = "scroll-pane",
                        style = "flib_naked_scroll_pane_no_padding",
                        --style_mods = {height = 200},
                        children = {
                            {
                                type = "table",
                                style = "slot_table",
                                -- style_mods = { width = 400 },
                                column_count = 10,
                                ref = { "displays", visual_signal_key, "slot_table" }
                            }
                        }
                    }
                }
            }
        }
    }
end

local function editable_title(_, visual_signal_key)
    local visual_signal_entry = global.visual_signals[visual_signal_key]
    return {
        type = "flow",
        direction = "vertical",
        children = {
            {
                type = "textfield",
                text = visual_signal_entry.title,
                actions = {
                    on_text_changed = { type = "big-gui", action = "title-change", key = visual_signal_key }
                }
            },
            {
                type = "frame",
                style = "slot_button_deep_frame",
                children = {
                    {
                        type = "scroll-pane",
                        style = "flib_naked_scroll_pane_no_padding",
                        --style_mods = {height = 200},
                        children = {
                            {
                                type = "table",
                                style = "slot_table",
                                -- style_mods = { width = 400 },
                                column_count = 10,
                                ref = { "displays", visual_signal_key, "slot_table" }
                            }
                        }
                    }
                }
            }
        }
    }
end

return {
    for_display = for_display,
    editable_title = editable_title,
    update = update
}
