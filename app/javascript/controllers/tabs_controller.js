import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static classes = ["active"]

  connect() {
    // Show the first tab by default if none are active
    if (!this.hasActiveTab) {
      this.showTab(0)
    }
  }

  switch(event) {
    event.preventDefault()
    const index = this.tabTargets.indexOf(event.currentTarget)
    this.showTab(index)
  }

  showTab(index) {
    this.tabTargets.forEach((tab, i) => {
      if (i === index) {
        tab.classList.add(...this.activeClasses)
        tab.setAttribute("aria-selected", "true")
      } else {
        tab.classList.remove(...this.activeClasses)
        tab.setAttribute("aria-selected", "false")
      }
    })

    this.panelTargets.forEach((panel, i) => {
      if (i === index) {
        panel.classList.remove("hidden")
      } else {
        panel.classList.add("hidden")
      }
    })
  }

  get hasActiveTab() {
    return this.tabTargets.some(tab => tab.classList.contains(this.activeClasses[0]))
  }
}
