package pace

import "core:fmt"
import "core:strings"
import "core:time"

// ============================================================================
// Bar
// ============================================================================

Bar :: struct {
	BarBase:   BarBase,
	runes:     BarRunes,
	pre, post: any,
	runes_:    BarRunes_,
}

setup_bar :: proc(b: ^Bar) {
	// Resolve runes to strings for color support
	indicator_rune := b.runes.progress
	if b.runes.indicator != nil {
		indicator_rune = b.runes.indicator^
	}
	b.runes_ = BarRunes_ {
		progress  = rune_to_string(b.runes.progress),
		remaining = rune_to_string(b.runes.remaining),
		indicator = rune_to_string(indicator_rune),
	}

	// Resolve affixes (use defaults if not set)
	pre_input := b.pre
	post_input := b.post
	if pre_input == nil {
		pre_input = "["
	}
	if post_input == nil {
		post_input = default_post_bar
	}
	b.pre = pre_input
	b.post = post_input
	b.BarBase.pre_ = resolve_bar_affix(pre_input, b)
	b.BarBase.post_ = resolve_bar_affix(post_input, b)
}

default_post_bar :: proc(b: ^Bar) -> (string, string) {
	eta, err := eta_(b^, 0)
	if err.kind != .none {
		eta = err_msg(err)
	}
	return fmt.tprintf(
		"] %d%% (%s)",
		pct_(b^),
		eta,
	), fmt.tprintf("] %d%%", pct_(b^))
}

progress_ :: proc(b: ^Bar) -> BarError {
	if b.runes_.progress == "" {
		setup_bar(b)
	}
	if b.BarBase.width == 0 || b.BarBase.state.pos >= b.BarBase.width {
		return make_bar_error(.already_finished, "")
	}
	if b.BarBase.state.time.start == 0 {
		b.BarBase.state.time = BarTime{time.to_unix_nanoseconds(time.now()), 0}
		hide_cursor()
		if !b.BarBase.multi {
			print_raw("\n")
		}
	}

	set_vals_bar(b)
	if b.BarBase.multi {
		return no_bar_error()
	}
	draw_bar(b^)
	if b.BarBase.state.pos >= b.BarBase.width {
		show_cursor()
	}
	return no_bar_error()
}

colorize_ :: proc(b: ^Bar, color: any) {
	setup_bar(b)
	if val, ok_bar := color.(BarColor); ok_bar {
		colorize_components_bar(b, val)
	} else if val, ok := color.(Color); ok {
		colorize_uni_bar(b, val)
	}
}

eta_ :: proc(b: Bar, delay: u8) -> (string, BarError) {
	if delay > 100 {
		return "", make_bar_error(.delay_exceeded, "")
	}
	pos := cast(u32)b.BarBase.state.pos
	width := cast(u32)b.BarBase.width
	if width == 0 || pos == 0 {
		return spinner_(b), no_bar_error()
	}
	if pos * 100 < width * cast(u32)delay {
		return spinner_(b), no_bar_error()
	}
	start_ns := b.BarBase.state.time.start
	last_change_ns := b.BarBase.state.time.last_change
	elapsed_ns := last_change_ns - start_ns
	elapsed_duration := time.Duration(elapsed_ns)
	seconds := time.duration_seconds(elapsed_duration)
	eta := seconds / cast(f64)pos * cast(f64)(width - pos)
	return fmt.tprintf("{:.1f}s", eta), no_bar_error()
}

pct_ :: proc(b: Bar) -> u16 {
	if b.BarBase.width == 0 {
		return 0
	}
	return(
		cast(u16)(cast(u32)b.BarBase.state.pos *
			100 /
			cast(u32)b.BarBase.width) \
	)
}

reset_ :: proc(b: ^Bar) {
	b.BarBase.state = {}
	setup_bar(b)
}

spinner_ :: proc(b: Bar) -> string {
	if b.BarBase.state.pos == 0 || b.BarBase.state.pos >= b.BarBase.width {
		return ""
	}
	runes := spinner_runes
	return rune_to_temporary_string(
		runes[(b.BarBase.state.pos - 1) % spinner_len],
	)
}

// ============================================================================
// Public API
// ============================================================================

progress_bar :: proc(b: ^Bar) -> BarError {
	return progress_(b)
}

colorize_bar :: proc(b: ^Bar, color: any) {
	colorize_(b, color)
}

pct_bar :: proc(b: Bar) -> u16 {
	return pct_(b)
}

eta_bar :: proc(b: Bar, delay: u8) -> (string, BarError) {
	return eta_(b, delay)
}

spinner_bar :: proc(b: Bar) -> string {
	return spinner_(b)
}

reset_bar :: proc(b: ^Bar) {
	reset_(b)
}

// ============================================================================
// Affix resolution for Bar
// ============================================================================

resolve_affixation_bar :: proc(input: any, b: ^Bar) -> (string, string) {
	if val, ok := input.(Affix); ok {
		return val.pending, val.finished
	}
	if val, ok := input.(string); ok {
		return val, val
	}
	if val, ok := input.(proc(_: ^Bar) -> (string, string)); ok {
		return val(b)
	}
	return "", ""
}


set_vals_bar :: proc(b: ^Bar) {
	b.BarBase.state.time.last_change = time.to_unix_nanoseconds(time.now())
	b.BarBase.state.pos += 1
	b.BarBase.pre_ = resolve_bar_affix(b.pre, b)
	b.BarBase.post_ = resolve_bar_affix(b.post, b)
}

draw_bar :: proc(b: Bar) {
	clear_previous_line()
	fmt.println(format_bar(b))
}

format_bar :: proc(b: Bar) -> string {
	pos := min(cast(int)b.BarBase.state.pos, cast(int)b.BarBase.width)
	width := cast(int)b.BarBase.width
	builder: strings.Builder
	strings.builder_init(&builder, context.temp_allocator)
	strings.write_string(&builder, b.BarBase.pre_)
	for _ in 0 ..< max(pos - 1, 0) {
		strings.write_string(&builder, b.runes_.progress)
	}
	if pos < width {
		strings.write_string(&builder, b.runes_.indicator)
	} else {
		strings.write_string(&builder, b.runes_.progress)
	}
	for _ in 0 ..< width - pos {
		strings.write_string(&builder, b.runes_.remaining)
	}
	strings.write_string(&builder, b.BarBase.post_)
	return strings.to_string(builder)
}

resolve_bar_affix :: proc(input: any, b: ^Bar) -> string {
	pending, finished := resolve_affixation_bar(input, b)
	if b.BarBase.state.pos >= b.BarBase.width {
		return finished
	}
	return pending
}

colorize_uni_bar :: proc(b: ^Bar, color: Color) {
	b.runes_ = BarRunes_ {
		progress  = paint(color, b.runes_.progress, .fg),
		indicator = paint(color, b.runes_.indicator, .fg),
		remaining = paint(color, b.runes_.remaining, .fg),
	}
}

colorize_components_bar :: proc(b: ^Bar, color: BarColor) {
	b.runes_ = BarRunes_ {
		progress  = paint_component(color.progress, b.runes_.progress),
		indicator = paint_component(color.indicator, b.runes_.indicator),
		remaining = paint_component(color.remaining, b.runes_.remaining),
	}
}
