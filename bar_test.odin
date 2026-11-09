package pace

import "core:mem"
import "core:testing"

@(test)
test_bar_percentage_counts_completed_steps :: proc(t: ^testing.T) {
	bar := Bar {
		BarBase = BarBase{width = 4, state = State{pos = 2}},
	}
	testing.expect_value(t, pct_bar(bar), 50)
}

@(test)
test_bar_affix_selects_finished_value :: proc(t: ^testing.T) {
	bar := Bar {
		BarBase = BarBase{width = 4, state = State{pos = 4}},
	}
	value := resolve_bar_affix(
		Affix{pending = "pending", finished = "finished"},
		&bar,
	)
	testing.expect_value(t, value, "finished")
}

@(test)
test_bar_format_clamps_progress :: proc(t: ^testing.T) {
	bar := Bar {
		BarBase = BarBase {
			width = 3,
			state = State{pos = 5},
			pre_ = "[",
			post_ = "]",
		},
		runes_ = BarRunes_{progress = "=", indicator = ">", remaining = "-"},
	}
	testing.expect_value(t, format_bar(bar), "[===]")
}

@(test)
test_eta_reports_invalid_delay :: proc(t: ^testing.T) {
	bar := Bar{}
	value, err := eta_bar(bar, 101)
	testing.expect_value(t, value, "")
	testing.expect_value(t, err.kind, ErrorKind.delay_exceeded)
}

@(test)
test_eta_uses_fractional_delay_threshold :: proc(t: ^testing.T) {
	bar := Bar {
		BarBase = BarBase{width = 10, state = State{pos = 2}},
	}
	value, err := eta_bar(bar, 25)
	testing.expect_value(t, value, "⠽")
	testing.expect_value(t, err.kind, ErrorKind.none)
}

@(test)
test_rune_conversion_returns_stable_utf8 :: proc(t: ^testing.T) {
	value := rune_to_string('⠽')
	defer mem.delete(value)
	testing.expect_value(t, value, "⠽")
}

@(test)
test_foreground_background_paint_preserves_both_colors :: proc(t: ^testing.T) {
	value := paint_fg_bg(FgBg{fg = .red, bg = .blue}, "x")
	defer mem.delete(value)
	testing.expect_value(t, value, "\x1b[44m\x1b[31mx\x1b[0m")
}
