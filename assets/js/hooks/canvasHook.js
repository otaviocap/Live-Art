import { CustomEvents } from "../utils";

export const canvasHook = {
	mounted() {
		window.addEventListener(CustomEvents.CanvasUpdate, (e) => {
			this.pushEvent("canvas-update", e.detail)
		});
	}
}