<div align="center">
    <img src="assets/banner.png"/>
	<h1>pace</h1>
    <div style="text-align: center; font-style: italic; margin-top: 0.5rem;">
		A small terminal progress-bar library written in [Odin](https://odin-lang.org).
    </div>
</div>


---

## Installation

Add this directory as a collection in your Odin project:

```sh
mimir add-col <path>
```

Use the import path configured for that collection and refer to the package as
`pace`.

## Quick start

Create a bar with a positive width and call `progress_bar` once per completed
step:

```odin
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

The bar renders on standard output, hides the terminal cursor while running,
and restores it when complete. The default prefix is `[`; the default suffix
shows the percentage and estimated time remaining.

## API

- `pace.progress_bar(&bar)` advances and renders the bar, returning a `BarError`.
- `pace.pct_bar(bar)` returns the completed percentage.
- `pace.eta_bar(bar, delay)` returns an ETA string and an error; `delay` must be
  between 0 and 100.
- `pace.reset_bar(&bar)` resets the bar for reuse.
- `pace.colorize_bar(&bar, color)` applies a `Color` or per-glyph `BarColor`.

`Bar.pre` and `Bar.post` may be strings, `Affix` values, or procedures that
return pending and finished strings. See [`doc.odin`](doc.odin) for the full
package documentation.
