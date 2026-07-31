import { Controller } from "@hotwired/stimulus"

// Auto-submit: debounced input → submits parent form via Turbo.
// Usage: <form data-controller="auto-submit" data-action="input->auto-submit#search">
//        <input data-auto-submit-target="input">
export default class extends Controller {
  static targets = ["input"]
  static values = { debounce: { type: Number, default: 250 } }

  connect() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, this.debounceValue)
  }
}
