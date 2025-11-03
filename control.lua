---------------------------------------------------------------------------------------------------
---[ control.lua ]---
---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Cargar las funciones comunes ]---
---------------------------------------------------------------------------------------------------

require("__" .. "YAIM0425-d00b-core" .. "__/control")

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

    --- Validación
    if This_MOD.action then return end

    --- Ejecución de las funciones
    This_MOD.reference_values()
    This_MOD.load_events()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.reference_values()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Combinación de teclas
    This_MOD.key_sequence = This_MOD.prefix .. This_MOD.name

    --- Estilos de las imagenes
    This_MOD.slot = {}
    This_MOD.slot.default = "inventory_slot"
    This_MOD.slot.deleted = "red_slot"
    This_MOD.slot.select = "green_slot"
    This_MOD.slot.empty = "slot"
    This_MOD.slot.new = "yellow_slot"
    This_MOD.slot.old = "inventory_slot"

    --- Posibles estados de la ventana
    This_MOD.action = {}
    This_MOD.action.none = nil
    This_MOD.action.import = 1
    This_MOD.action.export = 2
    This_MOD.action.apply = 3
    This_MOD.action.discard = 4
    This_MOD.action.build = 5

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Eventos programados ]---
---------------------------------------------------------------------------------------------------

function This_MOD.load_events()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Acciones comunes
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- --- Al crear la entidad
    -- script.on_event({
    --     defines.events.on_built_entity,
    --     defines.events.on_robot_built_entity,
    --     defines.events.script_raised_built,
    --     defines.events.script_raised_revive,
    --     defines.events.on_space_platform_built_entity,
    -- }, function(event)
    --     This_MOD.create_entity(This_MOD.create_data(event))
    -- end)

    --- Abrir o cerrar la interfaz
    script.on_event({
        This_MOD.key_sequence,
        defines.events.on_gui_closed
    }, function(event)
        This_MOD.toggle_gui(This_MOD.create_data(event))
    end)

    -- --- Al seleccionar otro canal
    -- script.on_event({
    --     defines.events.on_gui_selection_state_changed
    -- }, function(event)
    --     This_MOD.selection_channel(This_MOD.create_data(event))
    -- end)

    -- --- Al hacer clic en algún elemento de la ventana
    -- script.on_event({
    --     defines.events.on_gui_click
    -- }, function(event)
    --     This_MOD.button_action(This_MOD.create_data(event))
    -- end)

    -- --- Al seleccionar o deseleccionar un icon
    -- script.on_event({
    --     defines.events.on_gui_elem_changed
    -- }, function(event)
    --     This_MOD.add_icon(This_MOD.create_data(event))
    -- end)

    -- --- Validar el nuevo nombre al dar ENTER
    -- script.on_event({
    --     defines.events.on_gui_confirmed
    -- }, function(event)
    --     This_MOD.edit_channel_name(This_MOD.create_data(event))
    -- end)

    -- --- Al copiar las entidades
    -- script.on_event({
    --     defines.events.on_player_setup_blueprint
    -- }, function(event)
    --     This_MOD.create_blueprint(This_MOD.create_data(event))
    -- end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Muerte y reconstrucción de una entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- --- Muerte de la entidad
    -- script.on_event({
    --     defines.events.on_entity_died
    -- }, function(event)
    --     This_MOD.before_entity_died(This_MOD.create_data(event))
    -- end)

    -- --- Modificar el fantasma de reconstrucción
    -- script.on_event({
    --     defines.events.on_post_entity_died
    -- }, function(event)
    --     event.entity = event.ghost
    --     This_MOD.edit_ghost(This_MOD.create_data(event))
    -- end)

    -- --- Información de las antenas destruidas
    -- script.on_event({
    --     defines.events.on_tick
    -- }, function()
    --     This_MOD.after_entity_died()
    -- end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Acciones por tiempo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- script.on_nth_tick(20, function()
    --     --- La entidad tenga energía
    --     This_MOD.check_power()

    --     --- Forzar el cierre, en caso de ser necesario
    --     This_MOD.validate_gui()
    -- end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Acciones propias del MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    -- --- Copar la configuración de una antena en otra
    -- script.on_event({
    --     defines.events.on_entity_settings_pasted
    -- }, function(event)
    --     This_MOD.copy_paste_settings(This_MOD.create_data(event))
    -- end)

    -- --- Ocultar la superficie de las fuerzas recién creadas
    -- script.on_event({
    --     defines.events.on_force_created
    -- }, function(event)
    --     This_MOD.hide_surface(This_MOD.create_data(event))
    -- end)

    -- --- Combinar dos forces
    -- script.on_event({
    --     defines.events.on_forces_merged
    -- }, function(event)
    --     This_MOD.forces_merged(This_MOD.create_data(event))
    -- end)

    -- --- Al clonar una antena
    -- script.on_event({
    --     defines.events.on_entity_cloned
    -- }, function(event)
    --     local Event = GMOD.copy(event)
    --     Event.entity = event.destination
    --     This_MOD.create_entity(This_MOD.create_data(Event))
    --     This_MOD.copy_paste_settings(This_MOD.create_data(event))
    -- end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

function This_MOD.toggle_gui(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function validate_close()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if not Data.GUI.frame_main then return false end
        if Data.Event.input_name then
            if Data.Event.input_name == This_MOD.key_sequence then
                This_MOD.sound_close(Data)
                return true
            end
        end
        if Data.GUI.action == This_MOD.action.build then return false end
        if not Data.Event.element then return false end
        if Data.Event.element == Data.GUI.frame_main then
            This_MOD.sound_close(Data)
            return true
        end
        if Data.Event.element ~= Data.GUI.button_exit then return false end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Aprovado
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        return true

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    local function validate_open()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if not Data.Event.input_name then return false end
        if Data.Event.input_name ~= This_MOD.key_sequence then return false end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Abrir el GUI
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        return true

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function gui_destroy()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        Data.GUI.frame_main.destroy()
        Data.gPlayer.GUI = {}
        Data.GUI = Data.gPlayer.GUI
        Data.Player.opened = nil

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    local function gui_build()
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar los guiones del nombre
        local Prefix = string.gsub(This_MOD.prefix, "%-", "_")

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Crear el cuadro principal
        Data.GUI.frame_main = {}
        Data.GUI.frame_main.type = "frame"
        Data.GUI.frame_main.name = "frame_main"
        Data.GUI.frame_main.direction = "vertical"
        Data.GUI.frame_main = Data.Player.gui.screen.add(Data.GUI.frame_main)
        Data.GUI.frame_main.style = "frame"
        Data.GUI.frame_main.auto_center = true

        --- Indicar que la ventana esta abierta
        --- Cerrar la ventana al abrir otra ventana, presionar E o Esc
        Data.Player.opened = Data.GUI.frame_main

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Contenedor de la cabeza
        Data.GUI.flow_head = {}
        Data.GUI.flow_head.type = "flow"
        Data.GUI.flow_head.name = "flow_head"
        Data.GUI.flow_head.direction = "horizontal"
        Data.GUI.flow_head = Data.GUI.frame_main.add(Data.GUI.flow_head)
        Data.GUI.flow_head.style = Prefix .. "flow_head"

        --- Etiqueta con el titulo
        Data.GUI.label_title = {}
        Data.GUI.label_title.type = "label"
        Data.GUI.label_title.name = "title"
        Data.GUI.label_title.caption = { "starting-items" }
        Data.GUI.label_title = Data.GUI.flow_head.add(Data.GUI.label_title)
        Data.GUI.label_title.style = Prefix .. "label_title"

        --- Indicador para mover la ventana
        Data.GUI.empty_widget_head = {}
        Data.GUI.empty_widget_head.type = "empty-widget"
        Data.GUI.empty_widget_head.name = "empty_widget_head"
        Data.GUI.empty_widget_head = Data.GUI.flow_head.add(Data.GUI.empty_widget_head)
        Data.GUI.empty_widget_head.drag_target = Data.GUI.frame_main
        Data.GUI.empty_widget_head.style = Prefix .. "empty_widget"

        --- Contenedor
        Data.GUI.flow_1 = {}
        Data.GUI.flow_1.type = "flow"
        Data.GUI.flow_1.name = "flow_1"
        Data.GUI.flow_1.direction = "horizontal"
        Data.GUI.flow_1 = Data.GUI.flow_head.add(Data.GUI.flow_1)
        Data.GUI.flow_1.style = Prefix .. "flow_head_button"

        --- Botón para importar
        Data.GUI.button_import = {}
        Data.GUI.button_import.type = "sprite-button"
        Data.GUI.button_import.name = "button_import"
        Data.GUI.button_import.sprite = "utility/import"
        Data.GUI.button_import.tooltip = { "shortcut.import-string" }
        Data.GUI.button_import = Data.GUI.flow_1.add(Data.GUI.button_import)
        Data.GUI.button_import.style = Prefix .. "button_blue"

        --- Botón para exportar
        Data.GUI.button_export = {}
        Data.GUI.button_export.type = "sprite-button"
        Data.GUI.button_export.name = "button_export"
        Data.GUI.button_export.sprite = "utility/export"
        Data.GUI.button_export.tooltip = { "gui.export-to-string" }
        Data.GUI.button_export = Data.GUI.flow_1.add(Data.GUI.button_export)
        Data.GUI.button_export.style = Prefix .. "button_blue"

        --- Contenedor
        Data.GUI.flow_2 = {}
        Data.GUI.flow_2.type = "flow"
        Data.GUI.flow_2.name = "flow_2"
        Data.GUI.flow_2.direction = "horizontal"
        Data.GUI.flow_2 = Data.GUI.flow_head.add(Data.GUI.flow_2)
        Data.GUI.flow_2.style = Prefix .. "flow_head_button"

        --- Botón para cancelar los cambios
        Data.GUI.button_red = {}
        Data.GUI.button_red.type = "sprite-button"
        Data.GUI.button_red.name = "button_red"
        Data.GUI.button_red.sprite = "utility/close_fat"
        Data.GUI.button_red = Data.GUI.flow_2.add(Data.GUI.button_red)
        Data.GUI.button_red.style = Prefix .. "button_red"

        --- Botón para aplicar los cambios
        Data.GUI.button_green = {}
        Data.GUI.button_green.type = "sprite-button"
        Data.GUI.button_green.name = "button_green"
        Data.GUI.button_green.sprite = "utility/play"
        Data.GUI.button_green = Data.GUI.flow_2.add(Data.GUI.button_green)
        Data.GUI.button_green.style = Prefix .. "button_green"

        --- Contenedor
        Data.GUI.flow_3 = {}
        Data.GUI.flow_3.type = "flow"
        Data.GUI.flow_3.name = "flow_3"
        Data.GUI.flow_3.direction = "horizontal"
        Data.GUI.flow_3 = Data.GUI.flow_head.add(Data.GUI.flow_3)
        Data.GUI.flow_3.style = Prefix .. "flow_head_button"

        --- Botón de cierre
        Data.GUI.button_exit = {}
        Data.GUI.button_exit.type = "sprite-button"
        Data.GUI.button_exit.name = "button_exit"
        Data.GUI.button_exit.sprite = "utility/close"
        Data.GUI.button_exit.hovered_sprite = "utility/close_black"
        Data.GUI.button_exit.clicked_sprite = "utility/close_black"
        Data.GUI.button_exit = Data.GUI.flow_3.add(Data.GUI.button_exit)
        Data.GUI.button_exit.style = Prefix .. "button_close"

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Contenedor del cuerpo para el inventario
        Data.GUI.flow_items = {}
        Data.GUI.flow_items.type = "flow"
        Data.GUI.flow_items.name = "flow_items"
        Data.GUI.flow_items.direction = "vertical"
        Data.GUI.flow_items = Data.GUI.frame_main.add(Data.GUI.flow_items)
        Data.GUI.flow_items.style = Prefix .. "flow_vertival_8"
        Data.GUI.flow_items.visible = false

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_items = {}
        Data.GUI.frame_items.type = "frame"
        Data.GUI.frame_items.name = "frame_items"
        Data.GUI.frame_items.direction = "vertical"
        Data.GUI.frame_items = Data.GUI.flow_items.add(Data.GUI.frame_items)
        Data.GUI.frame_items.style = Prefix .. "frame_items"

        --- Barra de movimiento
        Data.GUI.scroll_pane = {}
        Data.GUI.scroll_pane.type = "scroll-pane"
        Data.GUI.scroll_pane.name = "scroll_pane"
        Data.GUI.scroll_pane.horizontal_scroll_policy = "never"
        Data.GUI.scroll_pane = Data.GUI.frame_items.add(Data.GUI.scroll_pane)

        --- Tabla contenedora
        Data.GUI.table = {}
        Data.GUI.table.type = "table"
        Data.GUI.table.name = "table"
        Data.GUI.table.column_count = 10
        Data.GUI.table = Data.GUI.scroll_pane.add(Data.GUI.table)
        Data.GUI.table.style = Prefix .. "table"

        --- Imagen a mostrar
        for i = 1, 40, 1 do
            Data.GUI[i] = {}
            Data.GUI[i].type = "sprite-button"
            Data.GUI[i].name = tostring(i)
            Data.GUI[i] = Data.GUI.table.add(Data.GUI[i])
            Data.GUI[i].style = "inventory_slot"
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Efecto de profundidad
        Data.GUI.frame_select = {}
        Data.GUI.frame_select.type = "frame"
        Data.GUI.frame_select.name = "frame_select"
        Data.GUI.frame_select = Data.GUI.flow_items.add(Data.GUI.frame_select)
        Data.GUI.frame_select.style = "entity_frame"

        --- Contenedor
        Data.GUI.flow_4 = {}
        Data.GUI.flow_4.type = "flow"
        Data.GUI.flow_4.name = "flow_4"
        Data.GUI.flow_4.direction = "horizontal"
        Data.GUI.flow_4 = Data.GUI.frame_select.add(Data.GUI.flow_4)
        Data.GUI.flow_4.style = Prefix .. "flow_select"

        --- Crear la imagen de selección
        Data.GUI[0] = {}
        Data.GUI[0].type = "choose-elem-button"
        Data.GUI[0].name = "0"
        Data.GUI[0].elem_type = "item"
        Data.GUI[0].elem_value = "iron-chest"
        Data.GUI[0] = Data.GUI.flow_4.add(Data.GUI[0])
        Data.GUI[0].style = This_MOD.slot.default

        --- Slider
        Data.GUI.slider = {}
        Data.GUI.slider.type = "slider"
        Data.GUI.slider.name = "slider"
        Data.GUI.slider.minimum_value = 0
        Data.GUI.slider.maximum_value = 10
        Data.GUI.slider.value_step = 1
        Data.GUI.slider = Data.GUI.flow_4.add(Data.GUI.slider)
        Data.GUI.slider.style = Prefix .. "slider"

        --- Valor del slider
        Data.GUI.textfield = {}
        Data.GUI.textfield.type = "textfield"
        Data.GUI.textfield.name = "textfield"
        Data.GUI.textfield.text = ""
        Data.GUI.textfield.numeric = true
        Data.GUI.textfield = Data.GUI.flow_4.add(Data.GUI.textfield)
        Data.GUI.textfield.style = "slider_value_textfield"

        --- Botón de confirmación
        Data.GUI.button_add = {}
        Data.GUI.button_add.type = "sprite-button"
        Data.GUI.button_add.name = "button_add"
        Data.GUI.button_add.sprite = "utility/check_mark_white"
        Data.GUI.button_add = Data.GUI.flow_4.add(Data.GUI.button_add)
        Data.GUI.button_add.style = Prefix .. "button_green"

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Contenedor en los pies
        Data.GUI.flow_confirm = {}
        Data.GUI.flow_confirm.type = "flow"
        Data.GUI.flow_confirm.name = "flow_confirm"
        Data.GUI.flow_confirm.direction = "horizontal"
        Data.GUI.flow_confirm = Data.GUI.flow_items.add(Data.GUI.flow_confirm)
        Data.GUI.flow_confirm.style = Prefix .. "flow_confirm"
        Data.GUI.flow_confirm.visible = false

        --- Botón para cancelar los cambios
        Data.GUI.button_cancel = {}
        Data.GUI.button_cancel.type = "sprite-button"
        Data.GUI.button_cancel.name = "button_cancel"
        Data.GUI.button_cancel.sprite = "utility/close_fat"
        Data.GUI.button_cancel = Data.GUI.flow_confirm.add(Data.GUI.button_cancel)
        Data.GUI.button_cancel.style = Prefix .. "button_red"

        --- Indicador para mover la ventana
        Data.GUI.empty_widget_foot_left = {}
        Data.GUI.empty_widget_foot_left.type = "empty-widget"
        Data.GUI.empty_widget_foot_left.name = "empty_widget_foot_left"
        Data.GUI.empty_widget_foot_left = Data.GUI.flow_confirm.add(Data.GUI.empty_widget_foot_left)
        Data.GUI.empty_widget_foot_left.drag_target = Data.GUI.frame_main
        Data.GUI.empty_widget_foot_left.style = Prefix .. "empty_widget"

        --- Mensaje de confirmación
        Data.GUI.label_title = {}
        Data.GUI.label_title.type = "label"
        Data.GUI.label_title.name = "title"
        Data.GUI.label_title.caption = { "gui.confirmation" }
        Data.GUI.label_title = Data.GUI.flow_confirm.add(Data.GUI.label_title)
        Data.GUI.label_title.style = Prefix .. "label_title"

        --- Indicador para mover la ventana
        Data.GUI.empty_widget_foot_right = {}
        Data.GUI.empty_widget_foot_right.type = "empty-widget"
        Data.GUI.empty_widget_foot_right.name = "empty_widget_foot_right"
        Data.GUI.empty_widget_foot_right = Data.GUI.flow_confirm.add(Data.GUI.empty_widget_foot_right)
        Data.GUI.empty_widget_foot_right.drag_target = Data.GUI.frame_main
        Data.GUI.empty_widget_foot_right.style = Prefix .. "empty_widget"

        --- Botón para aplicar los cambios
        Data.GUI.button_confirm = {}
        Data.GUI.button_confirm.type = "sprite-button"
        Data.GUI.button_confirm.name = "button_confirm"
        Data.GUI.button_confirm.sprite = "utility/check_mark_white"
        Data.GUI.button_confirm = Data.GUI.flow_confirm.add(Data.GUI.button_confirm)
        Data.GUI.button_confirm.style = Prefix .. "button_green"

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Contenedor del cuerpo para el inventario
        Data.GUI.flow_IO = {}
        Data.GUI.flow_IO.type = "flow"
        Data.GUI.flow_IO.name = "flow_IO"
        Data.GUI.flow_IO.direction = "vertical"
        Data.GUI.flow_IO = Data.GUI.frame_main.add(Data.GUI.flow_IO)
        Data.GUI.flow_IO.style = Prefix .. "flow_vertival_8"
        Data.GUI.flow_IO.visible = false

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Caja de texto a usar
        Data.GUI.textbox = {}
        Data.GUI.textbox.type = "text-box"
        Data.GUI.textbox.name = "textbox"
        Data.GUI.textbox = Data.GUI.flow_IO.add(Data.GUI.textbox)
        Data.GUI.textbox.word_wrap = true
        Data.GUI.textbox.style = Prefix .. "textbox"

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Acción a ejecutar
    if validate_close() then
        gui_destroy()
    elseif validate_open() then
        Data.GUI.action = This_MOD.action.build
        gui_build()
        Data.GUI.action = This_MOD.action.none
        This_MOD.sound_open(Data)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Funciones auxiliares ]---
---------------------------------------------------------------------------------------------------

function This_MOD.create_data(event)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Consolidar la información
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Data = GMOD.create_data(event or {}, This_MOD)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Renombrar los espacios
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Lista de objetos con confirmación
    Data.gMOD.The_list = Data.gMOD.The_list or {}
    Data.The_list = Data.gMOD.The_list

    --- Lista de objetos sin confirmación
    Data.gPlayer.My_list = Data.gPlayer.My_list or GMOD.copy(Data.The_list)
    Data.My_list = Data.gPlayer.My_list

    --- Lista de objeto entregados al jugador
    Data.gPlayer.Received = Data.gPlayer.Received or {}
    Data.Received = Data.gPlayer.Received

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Devolver el consolidado de los datos
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    return Data

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

function This_MOD.sound_open(Data)
    Data.Player.play_sound({ path = "entity-open/steel-chest" })
end

function This_MOD.sound_close(Data)
    Data.Player.play_sound({ path = "entity-close/steel-chest" })
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------------------------------
