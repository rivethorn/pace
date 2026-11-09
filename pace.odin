package pace

import "core:fmt"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

// ============================================================================
// Terminal helpers (ANSI escape codes, no external dependencies)
// ============================================================================

cursor_hide :: "\x1b[?25l"
cursor_show :: "\x1b[?25h"

print_raw :: proc(s: string) {
	os.write(os.stdout, transmute([]byte)s)
}

clear_previous_line :: proc() {
	print_raw("\x1b[1A\x1b[2K")
}

hide_cursor :: proc() {
	print_raw(cursor_hide)
}

show_cursor :: proc() {
	print_raw(cursor_show)
}

cursor_up :: proc(n: int) {
	print_raw(fmt.tprintf("\x1b[%dA", n))
}

rune_to_string :: proc(value: rune) -> string {
	bytes, length := utf8.encode_rune(value)
	return strings.clone(string(bytes[:length]))
}

rune_to_temporary_string :: proc(value: rune) -> string {
	bytes, length := utf8.encode_rune(value)
	return fmt.tprintf("%s", string(bytes[:length]))
}

// ============================================================================
// Shared state
// ============================================================================

BarTime :: struct {
	start:       i64,
	last_change: i64,
}

State :: struct {
	pos:  u16,
	time: BarTime,
}

BarBase :: struct {
	width: u16,
	state: State,
	multi: bool,
	pre_:  string,
	post_: string,
}

// ============================================================================
// Runes
// ============================================================================

BarRunes :: struct {
	progress:  rune,
	indicator: ^rune,
	remaining: rune,
}

BarRunes_ :: struct {
	progress:  string,
	indicator: string,
	remaining: string,
}

SmoothRunes :: struct {
	f:  []string,
	s:  []string,
	sm: []string,
}

smooth_ltr :: [9]rune {
	' ',
	'▏',
	'▎',
	'▍',
	'▌',
	'▋',
	'▊',
	'▉',
	'█',
}
smooth_rtl :: [9]rune {
	'█',
	'🮋',
	'🮊',
	'🮉',
	'▐',
	'🮈',
	'🮇',
	'▕',
	' ',
}
fillers :: [2]rune{'█', ' '}

spinner_runes :: [6]rune{'⠻', '⠽', '⠾', '⠷', '⠯', '⠻'}
spinner_len :: 6

// ============================================================================
// Affix
// ============================================================================

Affix :: struct {
	pending:  string,
	finished: string,
}

// ============================================================================
// Errors
// ============================================================================

ErrorKind :: enum {
	none,
	already_finished,
	delay_exceeded,
	missing_multi,
}

BarError :: struct {
	kind: ErrorKind,
	val:  string,
}

err_msg :: proc(err: BarError) -> string {
	switch err.kind {
	case .none:
		return ""
	case .already_finished:
		return "Trying to progress already finished bar."
	case .delay_exceeded:
		return "Delay cannot exceed 100%."
	case .missing_multi:
		return fmt.tprintf(
			"Failed drawing bars. []^Bar indices not set as multi: %s",
			err.val,
		)
	}
	return ""
}

make_bar_error :: proc(kind: ErrorKind, val: string) -> BarError {
	return BarError{kind, val}
}

no_bar_error :: proc() -> BarError {
	return make_bar_error(.none, "")
}
