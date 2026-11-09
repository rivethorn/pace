/*
A small terminal progress-bar package.

## Quick start

Create a bar with a positive width and rune glyphs, then call `progress_bar`
once for each completed step:

```
indicator := '>'
bar := pace.Bar{
	BarBase = pace.BarBase{width = 20},
	runes = pace.BarRunes{
		progress = '=',
		indicator = &indicator,
		remaining = ' ',
	},
}

for _ in 0..<bar.BarBase.width {
	err := pace.progress_bar(&bar)
	if err.kind != .none {
		panic(pace.err_msg(err))
	}
}
```

The bar writes to standard output, hides the terminal cursor while running,
and restores it after the final step. A zero-width bar cannot be progressed.

## Progress and errors

`progress_bar` returns a `BarError`. A `.none` kind indicates success;
`.already_finished` indicates the bar has reached its width. `eta_bar` returns
an ETA string and a `BarError`; its `delay` parameter must be between 0 and
100. `pct_bar` returns the completed percentage, and `reset_bar` resets a bar
for reuse.

## Affixes

`Bar.pre` and `Bar.post` accept a string, an `Affix`, or a procedure taking
`^Bar` and returning two strings. An `Affix`'s `pending` value is used while
the bar is running, and its `finished` value is used once the bar completes.
When omitted, the prefix is `[` and the suffix displays the percentage and ETA.

## Colors

`colorize_bar` accepts a `Color` to apply one foreground color to every bar
glyph, or a `BarColor` to set the progress, remaining, and indicator glyph
colors separately. Each `BarColor` component can be a `Color` or an `FgBg`
foreground/background pair.
*/
package pace
