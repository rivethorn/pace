package example

import pace "../"
import "core:time"

main :: proc() {
	indicator := '>'
	bar := pace.Bar {
		BarBase = pace.BarBase{width = 20},
		runes = pace.BarRunes {
			progress = '=',
			indicator = &indicator,
			remaining = '-',
		},
		pre = "[",
		post = pace.Affix{pending = "] Loading...", finished = "] Done!"},
	}

	pace.colorize_bar(&bar, pace.Color.green)

	for _ in 0 ..< bar.BarBase.width {
		err := pace.progress_bar(&bar)
		if err.kind != .none {
			panic(pace.err_msg(err))
		}
		time.sleep(250 * time.Millisecond)
	}
}
