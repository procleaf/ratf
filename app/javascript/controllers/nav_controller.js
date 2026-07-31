import { Controller } from "@hotwired/stimulus"

// Mobile nav toggle: hamburger button to show/hide sidebar.
export default class extends Controller {
  static targets = ["menu", "icon"]

  connect() {
    // Close menu when clicking a link (for mobile)
    this.menuTarget.querySelectorAll("a").forEach(link => {
      link.addEventListener("click", () => this.close())
    })
  }

  toggle() {
    this.menuTarget.classList.toggle("nav-open")
    if (this.hasIconTarget) {
      this.iconTarget.textContent = this.menuTarget.classList.contains("nav-open") ? "✕" : "☰"
    }
  }

  close() {
    this.menuTarget.classList.remove("nav-open")
    if (this.hasIconTarget) {
      this.iconTarget.textContent = "☰"
    }
  }
}
