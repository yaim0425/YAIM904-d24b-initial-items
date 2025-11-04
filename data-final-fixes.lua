---------------------------------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Información del MOD ]---
---------------------------------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores a usar en control.lua
    This_MOD.load_styles()
    This_MOD.key_sequence()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
--- [ Valores a usar en control.lua ] ---
---------------------------------------------------------------------------------------------------

function This_MOD.load_styles()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores a usar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar los guiones del nombre
    local Prefix = string.gsub(This_MOD.prefix, "%-", "_")

    --- Renombrar
    local Styles = data.raw["gui-style"].default

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Multiuso
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Styles[Prefix .. "flow_vertival_8"] = {
        type = "vertical_flow_style",
        vertical_spacing = 8
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cabeza
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Styles[Prefix .. "flow_head"] = {
        type = "horizontal_flow_style",
        horizontal_spacing = 8,
        bottom_padding = 7
    }

    Styles[Prefix .. "flow_head_button"] = {
        type = "horizontal_flow_style",
        horizontal_spacing = 3
    }

    Styles[Prefix .. "label_title"] = {
        type = "label_style",
        parent = "frame_title",
        button_padding = 3,
        top_margin = -3
    }

    Styles[Prefix .. "empty_widget"] = {
        type = "empty_widget_style",
        parent = "draggable_space",
        horizontally_stretchable = "on",
        vertically_stretchable = "on",
        height = 24
    }

    Styles[Prefix .. "button_blue"] = {
        type = "button_style",
        parent = "tool_button_blue",
        padding = 2,
        margin = 0,
        size = 24
    }

    Styles[Prefix .. "button_red"] = {
        type = "button_style",
        parent = "tool_button_red",
        padding = 2,
        margin = 0,
        size = 24
    }

    Styles[Prefix .. "button_green"] = {
        type = "button_style",
        parent = "tool_button_green",
        padding = 2,
        margin = 0,
        size = 24
    }

    Styles[Prefix .. "button_close"] = {
        type = "button_style",
        parent = "close_button",
        padding = 2,
        margin = 0,
        size = 24
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Items
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Styles[Prefix .. "frame_items"] = {
        type = "frame_style",
        parent = "entity_frame",
        maximal_height = 180,
        padding = 0
    }

    Styles[Prefix .. "table"] = {
        type = "table_style",
        horizontal_spacing = 0,
        vertical_spacing = 0,
    }

    Styles[Prefix .. "flow_select"] = {
        type = "horizontal_flow_style",
        vertical_align = "center",
        horizontal_spacing = 8
    }

    Styles[Prefix .. "slider"] = {
        type = "slider_style",
        parent = "notched_slider",
        horizontally_stretchable = "on"
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Importar y Exportar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Styles[Prefix .. "textbox"] = {
        type = 'textbox_style',
        width = 420,
        height = 248
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.key_sequence()
    local Table = {}
    Table.type = "custom-input"
    Table.name = This_MOD.prefix .. This_MOD.name
    Table.localised_name = { "description.initial-items" }
    Table.key_sequence = "CONTROL + I"
    data:extend({ Table })
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------------------------------
