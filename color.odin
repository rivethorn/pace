package pace

import "core:strings"

// ============================================================================
// Color types
// ============================================================================

Color :: enum {
	reset,
	black,
	red,
	green,
	yellow,
	blue,
	magenta,
	cyan,
	white,
	gray,
	bright_black,
	bright_red,
	bright_green,
	bright_yellow,
	bright_blue,
	bright_magenta,
	bright_cyan,
	bright_white,
}

FgBg :: struct {
	fg: Color,
	bg: Color,
}

BarColor :: struct {
	progress:  any,
	remaining: any,
	indicator: any,
}

Surface :: enum {
	fg,
	bg,
}

// ============================================================================
// ANSI escape code helpers
// ============================================================================

fg_ansi :: proc(c: Color) -> string {
	switch c {
	case .reset:
		return "\x1b[0m"
	case .black:
		return "\x1b[30m"
	case .red:
		return "\x1b[31m"
	case .green:
		return "\x1b[32m"
	case .yellow:
		return "\x1b[33m"
	case .blue:
		return "\x1b[34m"
	case .magenta:
		return "\x1b[35m"
	case .cyan:
		return "\x1b[36m"
	case .white:
		return "\x1b[37m"
	case .gray:
		return "\x1b[90m"
	case .bright_black:
		return "\x1b[90m"
	case .bright_red:
		return "\x1b[91m"
	case .bright_green:
		return "\x1b[92m"
	case .bright_yellow:
		return "\x1b[93m"
	case .bright_blue:
		return "\x1b[94m"
	case .bright_magenta:
		return "\x1b[95m"
	case .bright_cyan:
		return "\x1b[96m"
	case .bright_white:
		return "\x1b[97m"
	}
	return "\x1b[0m"
}

bg_ansi :: proc(c: Color) -> string {
	switch c {
	case .reset:
		return "\x1b[0m"
	case .black:
		return "\x1b[40m"
	case .red:
		return "\x1b[41m"
	case .green:
		return "\x1b[42m"
	case .yellow:
		return "\x1b[43m"
	case .blue:
		return "\x1b[44m"
	case .magenta:
		return "\x1b[45m"
	case .cyan:
		return "\x1b[46m"
	case .white:
		return "\x1b[47m"
	case .gray:
		return "\x1b[100m"
	case .bright_black:
		return "\x1b[100m"
	case .bright_red:
		return "\x1b[101m"
	case .bright_green:
		return "\x1b[102m"
	case .bright_yellow:
		return "\x1b[103m"
	case .bright_blue:
		return "\x1b[104m"
	case .bright_magenta:
		return "\x1b[105m"
	case .bright_cyan:
		return "\x1b[106m"
	case .bright_white:
		return "\x1b[107m"
	}
	return "\x1b[0m"
}

paint :: proc(c: Color, s: string, surface: Surface) -> string {
	code: string
	if surface == .fg {
		code = fg_ansi(c)
	} else {
		code = bg_ansi(c)
	}
	return strings.concatenate({code, s, fg_ansi(.reset)})
}

paint_fg_bg :: proc(colors: FgBg, s: string) -> string {
	return strings.concatenate(
		{bg_ansi(colors.bg), fg_ansi(colors.fg), s, fg_ansi(.reset)},
	)
}

paint_component :: proc(c: any, s: string) -> string {
	if val, ok := c.(Color); ok {
		return paint(val, s, .fg)
	}
	if val, ok := c.(FgBg); ok {
		return paint_fg_bg(val, s)
	}
	return s
}
