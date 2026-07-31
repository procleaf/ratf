import { Controller } from "@hotwired/stimulus"

// Live log monitor — polls for new content like 'tail -f'.
// Usage: <div data-controller="live-log" data-live-log-url-value="/logs/1/stream">
export default class extends Controller {
  static values = { url: String, interval: { type: Number, default: 1000 }, running: { type: Boolean, default: true } }
  static targets = ["body"]

  connect() {
    this.scrollToBottom()
    this.poll()
  }

  disconnect() {
    clearInterval(this.timer)
  }

  poll() {
    if (!this.runningValue) return
    this.timer = setInterval(() => this.fetch(), this.intervalValue)
  }

  async fetch() {
    try {
      const response = await fetch(this.urlValue, { headers: { "Accept": "text/plain" } })
      if (response.ok) {
        const text = await response.text()
        if (text !== this.bodyTarget.textContent) {
          const wasAtBottom = this.isAtBottom()
          this.bodyTarget.textContent = text
          if (wasAtBottom) this.scrollToBottom()
        }
      }
    } catch (e) { /* silent */ }
  }

  stop() {
    this.runningValue = false
    clearInterval(this.timer)
  }

  start() {
    this.runningValue = true
    this.poll()
  }

  toggle() {
    this.runningValue ? this.stop() : this.start()
  }

  isAtBottom() {
    const el = this.bodyTarget.parentElement
    return el.scrollHeight - el.scrollTop - el.clientHeight < 40
  }

  scrollToBottom() {
    const el = this.bodyTarget.parentElement
    el.scrollTop = el.scrollHeight
  }
}
