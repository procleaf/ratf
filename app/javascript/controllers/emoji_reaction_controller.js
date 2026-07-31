import { Controller } from "@hotwired/stimulus"

// Emoji reaction toggle: click → POST/DELETE → update count.
// Usage: <div data-controller="emoji-reaction" data-emoji-reaction-url-value="...">
//        <button data-action="click->emoji-reaction#toggle" data-emoji="👍">👍 <span class="reaction-count">3</span></button>
export default class extends Controller {
  static values = { url: String }

  async toggle(event) {
    const btn = event.currentTarget
    const emoji = btn.dataset.emoji
    const countEl = btn.querySelector(".reaction-count")
    const csrf = document.querySelector("meta[name='csrf-token']")?.content
    const isActive = btn.classList.contains("active")

    btn.classList.toggle("active")

    try {
      const method = isActive ? "DELETE" : "POST"
      const response = await fetch(this.urlValue, {
        method,
        headers: { "Content-Type": "application/json", "X-CSRF-Token": csrf, "Accept": "application/json" },
        body: JSON.stringify({ emoji: emoji })
      })

      if (response.ok) {
        const data = await response.json()
        countEl.textContent = data.count > 0 ? data.count : ""
      } else {
        btn.classList.toggle("active") // revert
      }
    } catch (e) {
      btn.classList.toggle("active") // revert
    }
  }
}
