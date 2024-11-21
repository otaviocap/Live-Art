import { getSvgPathFromStroke, options, CustomEvents } from './utils'
import { getStroke } from 'perfect-freehand'

import Pickr from '@simonwep/pickr';

let currentPath = null;
let currentPicker = null
let currentPathData = []

let currentColor = "black"



function enableColorPicker() {
	if (currentPicker == null) {
		currentPicker = Pickr.create({
			el: '#color-picker',
			theme: 'classic', // or 'monolith', or 'nano'
			components: {
				hue: true
			}
		});

		currentPicker
			.on("hide", instance => {
				instance.applyColor()
			})
			.on("save", (color, _instance) => {
				currentColor = "#" + color.toHEXA().join("")
			})
	}

}

function getCanvas() {
	return document.getElementById("svgCanvas")
}


function getNextPoint(e) {
	boundingBox = getCanvas().getBoundingClientRect()

	return [e.pageX - boundingBox.x, e.pageY - boundingBox.y, e.pressure]
}

function createPathElement(color) {
	const el = document.createElementNS('http://www.w3.org/2000/svg', 'path')
	el.setAttribute('fill', color)
	return el
}


function updatePoints(pathElement, data) {
	stroke = getStroke(data, options)
	pathData = getSvgPathFromStroke(stroke)

	pathElement.setAttribute("d", pathData)
}

function handlePointerDown(e) {
	e.target.setPointerCapture(e.pointerId);

	currentPath = createPathElement(currentColor)

	currentPathData = [getNextPoint(e)]

	updatePoints(currentPath, currentPathData)

	getCanvas().appendChild(currentPath)
}

function handlePointerMove(e) {
	if (e.buttons === 1 && currentPath != null) {
		currentPathData = [...currentPathData, getNextPoint(e)]
		updatePoints(currentPath, currentPathData)
	}
}

function handlePointerUp(e) {
	const event = new CustomEvent(CustomEvents.CanvasUpdate, { detail: { color: currentColor, data: [...currentPathData] } });
	window.dispatchEvent(event);

	currentPath = null;
	currentPathData = []

	setTimeout(100, () => {
		let canvas = getCanvas()
		canvas.removeChild(canvas.lastChild)
	})
}


// Phoenix LiveView event handlers
window.addEventListener("phx:enable_drawing", (e) => {

	canvas = getCanvas()

	canvas.onpointerdown = handlePointerDown
	canvas.onpointerup = handlePointerUp
	canvas.onpointermove = handlePointerMove

	enableColorPicker()
});

window.addEventListener("phx:disable_drawing", (e) => {
	canvas = getCanvas()

	canvas.onpointerdown = null
	canvas.onpointerup = null
	canvas.onpointermove = null

	currentPath = null;
	currentPicker = null
	currentPathData = []
});

window.addEventListener("phx:change_color", (e) => {
	currentColor = e.detail.color
});

window.addEventListener("phx:clear_canvas", (e) => {
	canvas = getCanvas();

	canvas.innerHTML = ""
});

window.addEventListener("phx:undo", (e) => {
	canvas = getCanvas();

	canvas.removeChild(canvas.lastChild)
});

window.addEventListener("phx:add_stroke", (e) => {
	canvas = getCanvas();


	let el = createPathElement(e.detail.color)
	updatePoints(el, e.detail.data)

	canvas.appendChild(el)
});


