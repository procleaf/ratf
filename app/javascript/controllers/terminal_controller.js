import { Controller } from "@hotwired/stimulus"

// Terminal controller — copy content to clipboard
export default class extends Controller {
  static targets = ["body"]

  async copy() {
    const text = this.bodyTarget.innerText
    try {
      await navigator.clipboard.writeText(text)
    } catch (e) {
      // Fallback
      const ta = document.createElement("textarea")
      ta.value = text
      document.body.appendChild(ta)
      ta.select()
      document.execCommand("copy")
      ta.remove()
    }
  }
}
