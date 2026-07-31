import { Controller } from "@hotwired/stimulus"

// Notification poller: polls /notifications/unread-count and updates a badge.
// Usage: <span data-controller="notifications"
//             data-notifications-url-value="/notifications/unread-count"
//             data-notifications-target="badge">0</span>
export default class extends Controller {
  static values = { url: String, interval: { type: Number, default: 30000 } }
  static targets = ["badge"]

  connect() {
    this.poll()
    this.timer = setInterval(() => this.poll(), this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  async poll() {
    try {
      const response = await fetch(this.urlValue, { headers: { "Accept": "application/json" } })
      if (response.ok) {
        const data = await response.json()
        if (this.hasBadgeTarget) {
          this.badgeTarget.textContent = data.count
          this.badgeTarget.style.display = data.count > 0 ? "inline" : "none"
        }
      }
    } catch (e) { /* silent */ }
  }
}
