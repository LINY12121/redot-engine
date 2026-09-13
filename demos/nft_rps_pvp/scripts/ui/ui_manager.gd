class_name UIManager
extends RefCounted

const INK := Color("#07111f")
const SURFACE := Color("#0d1b32")
const SURFACE_ALT := Color("#132646")
const CYAN := Color("#35d9ff")
const VIOLET := Color("#a873ff")
const LIME := Color("#b9ff4d")
const PINK := Color("#ff5bd6")
const TEXT := Color("#f1f7ff")
const MUTED := Color("#9bb1d0")
const DANGER := Color("#ff6685")

static func panel_style(background: Color, border: Color = Color.TRANSPARENT, radius: int = 18, border_width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style

static func make_label(text_value: String, font_size: int = 18, color: Color = TEXT, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

static func make_button(title: String, accent: Color = CYAN) -> Button:
	var button := Button.new()
	button.text = title
	button.custom_minimum_size = Vector2(0, 58)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", panel_style(SURFACE_ALT, accent, 15, 1))
	button.add_theme_stylebox_override("hover", panel_style(accent.darkened(0.72), accent.lightened(0.18), 15, 2))
	button.add_theme_stylebox_override("pressed", panel_style(accent.darkened(0.55), Color.WHITE, 15, 2))
	button.add_theme_stylebox_override("disabled", panel_style(SURFACE.darkened(0.1), Color("#44516a"), 15, 1))
	return button

static func make_card(background: Color = SURFACE, border: Color = CYAN) -> PanelContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", panel_style(background, border, 18, 1))
	return card

static func separator() -> ColorRect:
	var line := ColorRect.new()
	line.color = Color("#355178")
	line.custom_minimum_size = Vector2(0, 1)
	return line
