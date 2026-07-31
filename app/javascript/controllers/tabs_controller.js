import { Controller } from "@hotwired/stimulus"

// Simple tab switcher.
export default class extends Controller {
  static targets = ["tab", "panel"]

  switch(event) {
    const panelName = event.currentTarget.dataset.tabsPanel
    this.tabTargets.forEach(t => t.classList.toggle("active", t.dataset.tabsPanel === panelName))
    this.panelTargets.forEach(p => p.style.display = p.dataset.tabsPanel === panelName ? "" : "none")
  }
}
