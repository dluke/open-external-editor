# Copyright (c) 2018 Calvin Ikenberry.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

tool
extends EditorPlugin

const SHORTCUT_SCANCODE = KEY_E
const SHORTCUT_MODIFIERS = KEY_MASK_CTRL

const USE_EXTERNAL_EDITOR_SETTING = "text_editor/external/use_external_editor"
const EXEC_PATH_SETTING = "text_editor/external/exec_path"
const EXEC_FLAGS_SETTING = "text_editor/external/exec_flags"

var godot_version

var script_editor
var editor_settings
var button
var shortcut
var on_color = Color("#A5EFAC")

func _enter_tree():
	godot_version = Engine.get_version_info()
	if godot_version["major"] < 3:
		print("\"Open External Editor\" plugin requires Godot 3.0 or higher")
		return
	script_editor = get_editor_interface().get_script_editor()
	editor_settings = get_editor_interface().get_editor_settings()
	var input_event = InputEventKey.new()
	input_event.scancode = SHORTCUT_SCANCODE
	if SHORTCUT_MODIFIERS & KEY_MASK_ALT:
		input_event.alt = true
	if SHORTCUT_MODIFIERS & KEY_MASK_CMD:
		input_event.command = true
	if SHORTCUT_MODIFIERS & KEY_MASK_CTRL:
		input_event.control = true
	if SHORTCUT_MODIFIERS & KEY_MASK_META:
		input_event.meta = true
	if SHORTCUT_MODIFIERS & KEY_MASK_SHIFT:
		input_event.shift = true
	shortcut = ShortCut.new()
	shortcut.set_shortcut(input_event)

	button = ToolButton.new()
	button.text = "Ext. Editor"
	button.hint_tooltip = "toggle external editor (" + shortcut.get_as_text() + ")"
	button.connect("pressed", self, "toggle_use_external")
	var vbox1 = script_editor.get_child(0)
	var hbox1 = vbox1.get_child(0)
	hbox1.add_child(button)
	update_button_state()

func _exit_tree():
	if button != null:
		button.free()

func _input(event):
	if shortcut.is_shortcut(event) && !event.pressed && script_editor.is_visible_in_tree():
		toggle_use_external()

func toggle_use_external():
	var prev_state = editor_settings.get_setting(USE_EXTERNAL_EDITOR_SETTING)
	editor_settings.set_setting(USE_EXTERNAL_EDITOR_SETTING, !prev_state)
	update_button_state()

func update_button_state():
	var current_state = editor_settings.get_setting(USE_EXTERNAL_EDITOR_SETTING)
	if current_state == true:
		button.modulate = on_color
	else:
		button.modulate = Color(1,1,1,1)
