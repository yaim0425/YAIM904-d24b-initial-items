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

    --- Minimo de filas a mostrar
    This_MOD.slot_row_min = 5

    --- Simbolos a mostrar a
    This_MOD.string_length = 10

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

    --- Abrir el inventario
    script.on_event({
        defines.events.on_gui_opened
    }, function(event)
        This_MOD.open_inventory(This_MOD.create_data(event))
    end)

    --- Abrir o cerrar la interfaz
    script.on_event({
        This_MOD.key_sequence,
        defines.events.on_gui_closed
    }, function(event)
        This_MOD.toggle_gui(This_MOD.create_data(event))
    end)

    --- Al hacer clic en algún elemento de la ventana
    script.on_event({
        defines.events.on_gui_click
    }, function(event)
        This_MOD.button_action(This_MOD.create_data(event))
    end)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Acciones propias del MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Al mover el slider
    script.on_event({
        defines.events.on_gui_value_changed
    }, function(event)
        This_MOD.change_slider(This_MOD.create_data(event))
    end)

    --- Al cambiar la cantidad de la caja de texto
    script.on_event({
        defines.events.on_gui_text_changed
    }, function(event)
        This_MOD.change_text(This_MOD.create_data(event))
    end)

    --- Al seleccionar o deseleccionar un nuevo objeto
    script.on_event({
        defines.events.on_gui_elem_changed
    }, function(event)
        local Data = This_MOD.create_data(event)
        This_MOD.item_select(Data)
        This_MOD.item_clear(Data)
    end)

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

        if not Data.Player.admin then return false end
        if not This_MOD.gameplay_mode(Data) then return false end
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
        Data.GUI.label_title.caption = { "description.initial-items" }
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

        --- Contenedor para la confirmación
        Data.GUI.flow_confirm = {}
        Data.GUI.flow_confirm.type = "flow"
        Data.GUI.flow_confirm.name = "flow_confirm"
        Data.GUI.flow_confirm.direction = "horizontal"
        Data.GUI.flow_confirm = Data.GUI.frame_main.add(Data.GUI.flow_confirm)
        Data.GUI.flow_confirm.style = Prefix .. "flow_head"
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
        Data.GUI.flow_items = {}
        Data.GUI.flow_items.type = "flow"
        Data.GUI.flow_items.name = "flow_items"
        Data.GUI.flow_items.direction = "vertical"
        Data.GUI.flow_items = Data.GUI.frame_main.add(Data.GUI.flow_items)
        Data.GUI.flow_items.style = Prefix .. "flow_vertival_8"

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
        Data.GUI.scroll_pane.horizontal_scroll_policy = "auto"
        Data.GUI.scroll_pane = Data.GUI.frame_items.add(Data.GUI.scroll_pane)

        --- Tabla contenedora
        Data.GUI.table = {}
        Data.GUI.table.type = "table"
        Data.GUI.table.name = "table"
        Data.GUI.table.column_count = 10
        Data.GUI.table = Data.GUI.scroll_pane.add(Data.GUI.table)
        Data.GUI.table.style = Prefix .. "table"

        --- Imagen a mostrar
        for i = 1, 10 * This_MOD.slot_row_min, 1 do
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
        Data.GUI.slider.enabled = false

        --- Valor del slider
        Data.GUI.textfield = {}
        Data.GUI.textfield.type = "textfield"
        Data.GUI.textfield.name = "textfield"
        Data.GUI.textfield.text = ""
        Data.GUI.textfield.numeric = true
        Data.GUI.textfield = Data.GUI.flow_4.add(Data.GUI.textfield)
        Data.GUI.textfield.style = "slider_value_textfield"
        Data.GUI.textfield.enabled = false

        --- Botón de confirmación
        Data.GUI.button_add = {}
        Data.GUI.button_add.type = "sprite-button"
        Data.GUI.button_add.name = "button_add"
        Data.GUI.button_add.sprite = "utility/check_mark_white"
        Data.GUI.button_add = Data.GUI.flow_4.add(Data.GUI.button_add)
        Data.GUI.button_add.style = Prefix .. "button_green"
        Data.GUI.button_add.enabled = false

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
        This_MOD.show_MyList(Data)
        Data.GUI.action = This_MOD.action.none
        This_MOD.sound_open(Data)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.change_slider(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Data.GUI.textfield.text = tostring(Data.GUI.slider.slider_value)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.change_text(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Al cambiar la cantidad de la caja de texto
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if Data.Event.element == Data.GUI.textfield then
        local Text = Data.GUI.textfield.text
        local Value = tonumber(Text, 10) or 0
        if Value > Data.GUI.slider.get_slider_maximum() then
            Value = Data.GUI.slider.get_slider_maximum()
        end
        Data.GUI.slider.slider_value = Value
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Al cambiar el texto a importar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if Data.Event.element == Data.GUI.textbox then
        Data.GUI.button_green.enabled = Data.GUI.textfield.text ~= ""
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.item_select(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.GUI[0] then return end

    local name = Data.GUI[0].elem_value
    if not name then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Establecer los valores
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Deseleccionar el objeto
    if Data.GUI.Found then
        Data.GUI.Found = nil
        This_MOD.show_MyList(Data)
        Data.GUI[0].elem_value = name
    end

    --- Habilitar los elementos
    Data.GUI[0].style = This_MOD.slot.new
    Data.GUI.slider.enabled = true
    Data.GUI.button_add.enabled = true
    Data.GUI.textfield.enabled = true

    --- Establecer los valores
    local StackSize = prototypes.item[name].stack_size
    Data.GUI.slider.set_slider_minimum_maximum(0, 10 * StackSize)
    Data.GUI.slider.set_slider_value_step(StackSize)

    --- Buscar en la lista actual
    for i, item in pairs(Data.MyList) do
        if item.name == name then
            StackSize = item.count or 0
            Data.GUI[i].style = This_MOD.slot.select
            Data.GUI[0].style = This_MOD.slot.select
            Data.GUI.Found = item
            break
        end
    end

    --- Mostrar el valor
    Data.GUI.textfield.text = tostring(StackSize)
    Data.GUI.slider.slider_value = StackSize

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.item_clear(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.GUI[0] then return end

    local name = Data.GUI[0].elem_value
    if name then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Establecer los valores
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Dejar la selección del inventario
    if Data.GUI.Found then
        Data.GUI.Found = nil
        This_MOD.show_MyList(Data)
    end

    --- Limpiar los valores
    Data.GUI[0].style = This_MOD.slot.default
    Data.GUI.textfield.text = "0"
    Data.GUI.slider.slider_value = 0

    --- Deshabilitar los elementos
    Data.GUI.slider.enabled = false
    Data.GUI.button_add.enabled = false
    Data.GUI.textfield.enabled = false

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.button_action(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Variables a usar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Flag = false
    local EventID = 0

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    EventID = defines.events.on_gui_click
    Flag = Data.Event.name == EventID
    if not Flag then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---






    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Acciones
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cerrar la ventana
    Flag = Data.Event.element == Data.GUI.button_exit
    if Flag then
        This_MOD.toggle_gui(Data)
        return
    end

    --- Mostar donde convertir un string en la lista
    Flag = Data.Event.element == Data.GUI.button_import
    if Flag then
        This_MOD.show_import(Data)
        return
    end

    --- Mostrar la lista en un string
    Flag = Data.Event.element == Data.GUI.button_export
    if Flag then
        This_MOD.show_export(Data)
        return
    end

    --- Cancelar en la confirmación
    Flag = Data.Event.element == Data.GUI.button_cancel
    if Flag then
        This_MOD.show_MyList(Data)
        Data.GUI.Action = This_MOD.action.none
        Data.GUI.flow_head.visible = true
        Data.GUI.flow_confirm.visible = false
        return
    end

    --- Volver de importar y exportar
    Flag = Data.Event.element == Data.GUI.button_red
    Flag = Flag and Data.GUI.Action ~= This_MOD.action.none
    if Flag then
        Data.GUI.flow_IO.visible = false
        Data.GUI.Action = This_MOD.action.none
        This_MOD.show_MyList(Data)
        return
    end

    --- Se desea descartar los cambios
    Flag = Data.GUI.Action == This_MOD.action.none
    Flag = Flag or Data.GUI.Action == This_MOD.action.apply
    Flag = Flag and Data.Event.element == Data.GUI.button_red
    if Flag then
        Data.GUI.Action = This_MOD.action.discard
        This_MOD.show_confirm(Data)
        return
    end

    --- Se desea aplicar los cambios
    Flag = Data.GUI.Action == This_MOD.action.none
    Flag = Flag or Data.GUI.Action == This_MOD.action.discard
    Flag = Flag and Data.Event.element == Data.GUI.button_green
    if Flag then
        Data.GUI.Action = This_MOD.action.apply
        This_MOD.show_confirm(Data)
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Restaurar el listado inicial
    local function Discard()
        local gToGive = GMOD.copy(Data.TheList)
        Data.gPlayer.MyList = gToGive
        Data.MyList = gToGive
        This_MOD.show_MyList(Data)

        --- Restaurar el titulo
        Data.GUI.Action = This_MOD.action.none
        Data.GUI.flow_head.visible = true
        Data.GUI.flow_confirm.visible = false
    end

    --- Convertir String en el listado
    local function Import()
        --- Guardar la nueva lista objeto
        local Text = Data.GUI.textbox.text
        local JSON = helpers.decode_string(Text)

        if not JSON then
            This_MOD.show_import(Data)
            This_MOD.print_global(Data, {
                "failed-to-import-string",
                "[color=default]" ..
                string.sub(Text, 1, This_MOD.string_length) ..
                "[/color]" ..
                (string.len(Text) > This_MOD.string_length and ".." or "")
            })
            return
        end

        local Items = helpers.json_to_table(JSON) or {}
        if #Items == 0 then
            This_MOD.show_import(Data)
            This_MOD.print_global(Data, {
                "failed-to-import-string",
                "[color=default]" ..
                string.sub(Text, 1, This_MOD.string_length) ..
                "[/color]" ..
                (string.len(Text) > This_MOD.string_length and ".." or "")
            })
            return
        end

        --- Validar los objetos
        local Remove = {}

        for key, items in pairs(Items) do
            if not prototypes.item[items.name] then
                table.insert(Remove, 1, key)
            end
        end

        for _, key in pairs(Remove) do
            table.remove(Items, key)
        end

        --- Acutualizar la lista
        Data.gPlayer.MyList = Items
        Data.MyList = Items

        --- Mostar la nueva lista
        Data.GUI.flow_IO.visible = false
        Data.GUI.Action = This_MOD.action.none
        This_MOD.show_MyList(Data)
    end

    --- Entregar los objetos enlistados
    local function Apply()
        --- Cerrar la interfaz
        Data.Event.element = Data.GUI.button_exit
        This_MOD.toggle_gui(Data)

        --- Eliminar los objetos en ceros
        local Remove = {}

        for key, MyList in pairs(Data.MyList) do
            if not MyList.count then
                table.insert(Remove, 1, key)
            end
        end

        for _, key in pairs(Remove) do
            table.remove(Data.MyList, key)
        end

        --- Actualizar la lista
        Data.gMOD.TheList = Data.MyList
        Data.TheList = Data.MyList

        local MyList = GMOD.copy(Data.MyList)
        Data.gPlayer.MyList = MyList
        Data.MyList = MyList

        --- Informar del cambio
        This_MOD.print_player(Data, { "gui-migrated-content.changed-item" })
    end

    --- Agregar el nuevo objeto a la lista
    local function Add_MyList()
        --- Valores a usar
        local Text = Data.GUI.textfield.text
        local Count = tonumber(Text) or 0

        --- Eliminar de la lista
        if Data.GUI.Found and Count == 0 then
            local Found = false
            for _, item in pairs(Data.TheList) do
                Found = item.name == Data.GUI.Found.name
                if Found then break end
            end
            if not Found then
                local i = GMOD.get_key(Data.MyList, Data.GUI.Found)
                table.remove(Data.MyList, i)
                Data.GUI.Found = nil
            end
        end

        --- Actualizar la cantidad
        if Data.GUI.Found then
            Data.GUI.Found.count = Count > 0 and Count or nil
        end

        --- Agregar un nuevo objeto
        if not Data.GUI.Found and Count > 0 then
            table.insert(Data.MyList, {
                name = Data.GUI[0].elem_value,
                count = Count > 0 and Count or nil,
            })

            --- Ordenar MyList
            local Level_1 = {}
            for _, item in pairs(Data.MyList) do
                --- Variables a usar
                local Item = prototypes.item[item.name]
                local Subgroup = Item.subgroup
                local Group = Item.subgroup.group

                --- Crear la jerarquia
                local Level_2 = Level_1[Group.order] or {}
                Level_1[Group.order] = Level_2

                local Level_3 = Level_2[Subgroup.order] or {}
                Level_2[Subgroup.order] = Level_3

                Level_3[Item.order] = item
            end

            --- Variable de salida
            local result = {}

            -- Función auxiliar para ordenar keys de una tabla
            local function getSortedKeys(level)
                local keys = {}
                for key in pairs(level) do
                    table.insert(keys, key)
                end
                table.sort(keys)
                return keys
            end

            -- Recorremos en orden cada nivel
            local Keys_1 = getSortedKeys(Level_1)
            for _, Key_1 in ipairs(Keys_1) do
                local Level_2 = Level_1[Key_1]
                local Keys_2 = getSortedKeys(Level_2)
                for _, Key_2 in ipairs(Keys_2) do
                    local Level_3 = Level_2[Key_2]
                    local Keys_3 = getSortedKeys(Level_3)
                    for _, Key_3 in ipairs(Keys_3) do
                        table.insert(result, Level_3[Key_3])
                    end
                end
            end

            --- Actualizar la lista
            Data.gPlayer.MyList = result
            Data.MyList = result
        end

        --- Establecer el valor
        This_MOD.show_MyList(Data)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Agregar un objeto a la lista
    Flag = Data.Event.element == Data.GUI.button_add
    if Flag then
        Add_MyList()
        return
    end

    --- Convertir String en el listado
    Flag = Data.Event.element == Data.GUI.button_green
    Flag = Flag and Data.GUI.Action == This_MOD.action.import
    if Flag then
        Import()
        return
    end

    --- Guardar los cambios
    --- Entregar los objetos en la lista
    Flag = Data.Event.element == Data.GUI.button_confirm
    Flag = Flag and Data.GUI.Action == This_MOD.action.apply
    if Flag then
        if Data.gMOD.Block_implication then
            This_MOD.print_player(Data, { "gui-selector.feature-disabled" })
        else
            Data.gMOD.Block_implication = true
            for _, player in pairs(game.connected_players) do
                This_MOD.insert_items(This_MOD.create_data({ Player = player }))
            end
            Apply()
            Data.gMOD.Block_implication = nil
        end
        return
    end

    --- Restaurar la lista inicial
    Flag = Data.Event.element == Data.GUI.button_confirm
    Flag = Flag and Data.GUI.Action == This_MOD.action.discard
    if Flag then
        Discard()
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Vaidar un botón en la tabla
    local i = tonumber(Data.Event.element.name) or 0
    if i == 0 or i > #Data.MyList then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Seleccionar objeto desde la tabla
    local function Select()
        --- Restaurar cuadro selección
        if Data.GUI.Action ~= This_MOD.action.none then
            Data.GUI.Action = This_MOD.action.none
            This_MOD.show_MyList(Data)
        end

        --- Seleccionar lo seleccionado
        Flag = Data.GUI.Found
        Flag = Flag and Data.GUI.Found.name == Data.MyList[i].name

        --- Liberar la selección
        if Flag then
            Data.GUI[0].elem_value = nil
            This_MOD.Item_clear(Data)
        end

        --- Actual seleccionado
        if not Flag then
            Data.GUI[0].elem_value = Data.MyList[i].name
            This_MOD.item_select(Data)
        end
    end

    --- Eliminar objeto desde la tabla
    local function Remove()
        --- Guardar el objeto selecionado
        local name = Data.GUI[0].elem_value

        --- Buscar en el listado a entregar
        local Found = false
        for _, item in pairs(Data.TheList) do
            Found = item.name == Data.MyList[i].name
            if Found then break end
        end

        --- "Remover objeto"
        if Found then
            --- Remover de la lista
            Data.MyList[i].count = nil
        else
            --- Remover el objeto de la tabla
            table.remove(Data.MyList, i)
        end

        --- Mostrar la nueva lista
        This_MOD.show_MyList(Data)

        --- Restaurar objeto selecionado
        if name then
            Data.GUI[0].elem_value = name
            This_MOD.item_select(Data)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Seleccionar objeto desde la tabla
    EventID = defines.mouse_button_type.left
    Flag = Data.Event.button == EventID
    if Flag then
        Select()
        return
    end

    --- Borrar objeto desde la tabla
    EventID = defines.mouse_button_type.right
    Flag = Data.Event.button == EventID
    if Flag then
        Remove()
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.open_inventory(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if Data.Event.gui_type ~= defines.gui_type.controller then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Agregar los objetos a los jugadores
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.insert_items(Data)

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
    Data.gMOD.TheList = Data.gMOD.TheList or {}
    Data.TheList = Data.gMOD.TheList

    --- Lista de objetos sin confirmación
    Data.gPlayer.MyList = Data.gPlayer.MyList or GMOD.copy(Data.TheList)
    Data.MyList = Data.gPlayer.MyList

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

function This_MOD.show_MyList(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validar si hay diferencia
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local MyList = helpers.encode_string(helpers.table_to_json(Data.MyList))
    local gToGive = helpers.encode_string(helpers.table_to_json(Data.TheList))
    local Diff = MyList ~= gToGive

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Botones
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Data.GUI.button_import.enabled = true
    Data.GUI.button_export.enabled = #Data.MyList > 0
    Data.GUI.button_red.enabled = Diff
    Data.GUI.button_green.enabled = Diff

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Actualizar la tabla
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Limpiar la tabla
    Data.GUI.table.clear()

    --- Recorrer los objetos
    for i, MyItem in pairs(Data.MyList) do
        --- Agregar los objetos
        Data.GUI[i] = {}
        Data.GUI[i].type = "sprite-button"
        Data.GUI[i].name = tostring(i)
        Data.GUI[i].tags = MyItem
        Data.GUI[i].sprite = "item/" .. MyItem.name
        Data.GUI[i].number = MyItem.count
        Data.GUI[i] = Data.GUI.table.add(Data.GUI[i])

        --- Color del fondo
        Data.GUI[i].style = (function()
            for _, TheItem in pairs(Data.TheList) do
                if MyItem.name == TheItem.name then
                    if not MyItem.count then
                        return This_MOD.slot.deleted
                    elseif MyItem.count == TheItem.count then
                        return This_MOD.slot.old
                    end
                end
            end
            return This_MOD.slot.new
        end)()
    end

    --- Rellenar la tabla
    local iList = #Data.MyList
    local Max = 10 * This_MOD.slot_row_min
    local Left = iList % 10
    if Left > 0 and iList > Max then Max = iList + (10 - Left) end
    for i = iList + 1, Max, 1 do
        Data.GUI[i] = {}
        Data.GUI[i].type = "sprite-button"
        Data.GUI[i].name = tostring(i)
        Data.GUI[i] = Data.GUI.table.add(Data.GUI[i])
        Data.GUI[i].style = This_MOD.slot.empty
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Preparar la selección
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Data.GUI.frame_select.visible = true
    Data.GUI[0].elem_value = nil
    This_MOD.item_clear(Data)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Inicializar los valores
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Data.GUI.flow_items.visible = true

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.show_import(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Botones
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Data.GUI.button_import.enabled = false
    Data.GUI.button_export.enabled = #Data.MyList > 0
    Data.GUI.button_red.enabled = true
    Data.GUI.button_green.enabled = false

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Inicializar los valores
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Data.GUI.flow_items.visible = false
    Data.GUI.textbox.text =
    "eNqNlMtuAjEMRf9l1kSCvqTyK1UXmRl3sEji1HFKq4p/rwFREqR5rH1yfW3HfvttgvXQbBthi8Ekodismo5ykGb7sj6u/gFHAybBzjC1JDfo4bmkVIDtAKbbQSqgxwpi+MwaBr7HHtYlFumgSDqgdLsbUylZIa+WWvLtjXitDJGzbKIN4IymxeghFBmfqhJt0oSSmaFCSuZA1EO4N16ZQqZpQEtXN9PEpY1iw34E0YGFFInFtOAKnU1l98MmMctQ+I4MKS2kc+iBB9ZQf8dVLtvs9gaD9lXHPcKcPS7Uu5pciKfoUGYyzzDXjDNYmzno55kpdSbsKAxmZ7W2flHTZpjkrdNf76AT1i2J5GCE9NBj9ovQFodFXMptEitIYQSIGGHsd51iRshcJjwmkH0cCekxc2Pap5hJOATrJl7rep4P4hTnqCNPgl9lD4p4Z3kgc7BD1YNyiC5jPwVYFnQO+GcK0jRFreWJqK7HptoL1P0RLiU3x/c/lI0EwQ=="
    -- Data.GUI.textbox.text = ""
    Data.GUI.textbox.read_only = false
    Data.GUI.flow_IO.visible = true

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Acción en ejecucción
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Data.GUI.Action = This_MOD.action.import

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Enfocar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Data.GUI.textbox.focus()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.show_export(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Botones
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Data.GUI.button_import.enabled = true
    Data.GUI.button_export.enabled = false
    Data.GUI.button_red.enabled = true
    Data.GUI.button_green.enabled = false

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Inicializar los valores
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Data.GUI.flow_items.visible = false
    Data.GUI.textbox.text = ""
    Data.GUI.textbox.read_only = true
    Data.GUI.flow_IO.visible = true

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Acción en ejecucción
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Data.GUI.Action = This_MOD.action.export

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Limipiar y enfocar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    Data.GUI.textbox.text = helpers.table_to_json(Data.MyList)
    Data.GUI.textbox.text = helpers.encode_string(Data.GUI.textbox.text)
    Data.GUI.textbox.select_all()
    Data.GUI.textbox.focus()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.show_confirm(Data)
    --- Inicializar todo
    Data.GUI.Found = nil
    This_MOD.show_MyList(Data)

    --- Botones
    Data.GUI.button_red.enabled = Data.GUI.Action ~= This_MOD.action.discard
    Data.GUI.button_green.enabled = Data.GUI.Action ~= This_MOD.action.apply

    --- Mostrar mensaje de confirmación
    Data.GUI.flow_head.visible = false
    Data.GUI.flow_confirm.visible = true
end

function This_MOD.gameplay_mode(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validar el modo del jugador
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores a utilizar
    local Controller = Data.Player.controller_type
    local isCharacter = Controller == defines.controllers.character
    local isGod = Controller == defines.controllers.god
    if not isGod and not isCharacter then return false end

    --- Renombrar las variables
    local Level = script.level.level_name

    --- Variable a usar
    local Flag = false

    --- Está en el destino final
    Flag = Level == "wave-defense"
    Flag = Flag and Data.Player.surface.index == 1
    if Flag then return false end

    Flag = Level == "team-production"
    Flag = Flag and Data.Player.force.index == 1
    if Flag then return false end

    Flag = Level == "pvp"
    Flag = Flag and Data.Player.force.index == 1
    if Flag then return false end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Modo valido
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    return true

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.insert_items(Data)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Establecer los objetos a entregar y su cantidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for _, TheItem in pairs(Data.TheList) do
        --- Validar si el objeto ha sido entregado con anterioridad
        local Item = GMOD.get_tables(Data.Received, "name", TheItem.name)
        Item = Item and Item[1] or {}

        --- Se incremento la cantidad
        if Item.name and TheItem.count > Item.count then
            Item.count = TheItem.count
        end

        --- Primera vez en entregar el objeto
        if not Item.name then
            Item = GMOD.copy(TheItem)
            Item.gived = 0
            table.insert(Data.Received, Item)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Modo de juego
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not This_MOD.gameplay_mode(Data) then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Agregar los objetos
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Indicador para el inventory lleno
    Data.gPlayer.Full_inventory = false

    --- El jugador no tiene un cuerpo
    if not Data.Player.character then
        for _, Item in pairs(Data.Received) do
            local count = Item.count - Item.gived
            if count > 0 then
                local item = { name = Item.name, count = count }
                Item.gived = Item.gived + Data.Player.insert(item)
                Data.gPlayer.Full_inventory = Data.gPlayer.Full_inventory or Item.gived ~= Item.count
            end
        end
    end

    --- El jugador tiene un cuerpo
    if Data.Player.character then
        local Inventory = Data.Player.character
        local IDInvertory = defines.inventory.character_main
        Inventory = Inventory.get_inventory(IDInvertory)
        for _, Item in pairs(Data.Received) do
            local count = Item.count - Item.gived
            if count > 0 then
                local item = { name = Item.name, count = count }
                Item.gived = Item.gived + Inventory.insert(item)
                Data.gPlayer.Full_inventory = Data.gPlayer.Full_inventory or Item.gived ~= Item.count
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Informar del inventario
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not Data.gPlayer.Full_inventory then
        Data.gPlayer.Full_inventory = nil
    end

    if Data.gPlayer.Full_inventory then
        This_MOD.print_player(Data, { "inventory-full-message.main" })
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

function This_MOD.get_format(Data, msg)
    return { "",
        "[color=default]",
        { "description.initial-items" },
        ":[/color]",

        " ",

        "[img=entity/character]" ..
        "[color=" ..
        Data.Player.color.r .. "," ..
        Data.Player.color.g .. "," ..
        Data.Player.color.b ..
        "]",
        Data.Player.name,
        "[/color]",

        " ",

        msg
    }
end

function This_MOD.print_player(Data, msg)
    Data.Player.print(This_MOD.get_format(Data, msg))
end

function This_MOD.print_global(Data, msg)
    game.print(This_MOD.get_format(Data, msg))
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
