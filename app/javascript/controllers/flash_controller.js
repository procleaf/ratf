import { Controller } from "@hotwired/stimulus"

// Auto-dismiss flash messages after 5 seconds
// Usage: <div class="flash" data-controller="flash">
export default class extends Controller {
  static targets = ["dismiss"]

  connect() {
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.style.transition = "opacity 0.3s"
    this.element.style.opacity = "0"
    setTimeout(() => this.element.remove(), 300)
  }
}
