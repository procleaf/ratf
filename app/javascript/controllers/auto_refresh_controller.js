import { Controller } from "@hotwired/stimulus"

// Auto-refresh: polls a URL on a timer and replaces target content.
// Usage: <div data-controller="auto-refresh" data-auto-refresh-url-value="/dashboard/stats" data-auto-refresh-interval-value="5000">
//        <div data-auto-refresh-target="content">...</div>
//        </div>
export default class extends Controller {
  static values = { url: String, interval: { type: Number, default: 5000 } }
  static targets = ["content"]

  connect() {
    this.timer = setInterval(() => this.refresh(), this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  async refresh() {
    try {
      const response = await fetch(this.urlValue, { headers: { "Accept": "text/vnd.turbo-stream.html" } })
      if (response.ok) {
        const html = await response.text()
        const doc = new DOMParser().parseFromString(html, "text/html")
        doc.querySelectorAll("turbo-stream").forEach(el => {
          document.documentElement.querySelector("turbo-stream")?.remove()
          document.body.appendChild(el)
        })
      }
    } catch (e) { /* silent */ }
  }
}
