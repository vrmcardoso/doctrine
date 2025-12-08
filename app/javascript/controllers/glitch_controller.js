import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
        "layerCTop", "layerCBottom",
        "layerMTop", "layerMBottom",
        "layerGTop", "layerGBottom"
    ]

    connect() {
        this.scheduleNextGlitch()
    }

    disconnect() {
        if (this.timeout) clearTimeout(this.timeout)
    }

    scheduleNextGlitch() {
        // Random delay between 1s and 5s for sporadic feel
        const delay = 1000 + Math.random() * 4000
        this.timeout = setTimeout(() => {
            this.triggerGlitchBurst()
            this.scheduleNextGlitch()
        }, delay)
    }

    triggerGlitchBurst() {
        // 1. Pick a random color group to exploit
        const groupIndex = Math.floor(Math.random() * 3)
        let topLayer, bottomLayer

        if (groupIndex === 0) {
            topLayer = this.layerCTopTarget
            bottomLayer = this.layerCBottomTarget
        } else if (groupIndex === 1) {
            topLayer = this.layerMTopTarget
            bottomLayer = this.layerMBottomTarget
        } else {
            topLayer = this.layerGTopTarget
            bottomLayer = this.layerGBottomTarget
        }

        // 2. Define High Intensity
        // Solid light look: opacity 0.85 to 1.0
        const opacity = 0.85 + Math.random() * 0.15
        // Violent shear force: 25px to 50px shift
        const shearForce = 25 + Math.random() * 25
        // Randomize direction (left-over-right or right-over-left)
        const dir = Math.random() > 0.5 ? 1 : -1

        // 3. Define the fracture line (Coordinated Split)
        // A random horizontal line between 20% and 80% down the text height
        const splitY = 20 + Math.random() * 60

        // 4. Apply coordinated tearing

        // --- Top Half ---
        // Shows everything from top (0%) down to the split line.
        // Shifts violently in one horizontal direction, plus minor vertical jitter.
        topLayer.style.opacity = opacity.toString()
        // inset(top right bottom left) -> Bottom inset defines the split line from the bottom up
        topLayer.style.clipPath = `inset(0 0 ${100 - splitY}% 0)`
        topLayer.style.transform = `translate(${shearForce * dir}px, ${(Math.random() - 0.5) * 5}px)`

        // --- Bottom Half ---
        // Shows everything from the split line down to the bottom (100%).
        // Shifts violently in the OPPOSITE horizontal direction.
        bottomLayer.style.opacity = opacity.toString()
        // Top inset defines the split line from the top down
        bottomLayer.style.clipPath = `inset(${splitY}% 0 0 0)`
        bottomLayer.style.transform = `translate(${-shearForce * dir}px, ${(Math.random() - 0.5) * 5}px)`

        // Reset quickly for a flash effect
        setTimeout(() => {
            this.resetLayers([topLayer, bottomLayer])
        }, 150)
    }

    resetLayers(layers) {
        layers.forEach(layer => {
            layer.style.opacity = "0"
            layer.style.transform = "none"
            layer.style.clipPath = "none"
        })
    }
}