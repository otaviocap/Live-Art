export function getSvgPathFromStroke(stroke) {
	if (!stroke.length) return ""

	const d = stroke.reduce(
		(acc, [x0, y0], i, arr) => {
			const [x1, y1] = arr[(i + 1) % arr.length]
			acc.push(x0, y0, (x0 + x1) / 2, (y0 + y1) / 2)
			return acc
		},
		["M", ...stroke[0], "Q"]
	)

	d.push("Z")
	return d.join(" ")
}

export const options = {
	size: 12,
	thinning: 0.5,
	smoothing: 0.5,
	streamline: 0.5,
	easing: (t) => t,
	start: {
		taper: 0,
		easing: (t) => t,
		cap: true
	},
	end: {
		taper: 100,
		easing: (t) => t,
		cap: true
	}
};

export const CustomEvents = {
	CanvasUpdate: "LiveArt:update-canvas"
}