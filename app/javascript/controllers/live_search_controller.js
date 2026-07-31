import { Controller } from "@hotwired/stimulus"

// Live search: debounced input → fetch filtered results → replace table body.
// Usage: <div data-controller="live-search" data-live-search-url-value="/jobs">
//        <input data-live-search-target="input" data-action="input->live-search#search" placeholder="Search...">
//        <div data-live-search-target="results">...</div>
//        </div>
export default class extends Controller {
  static values = { url: String, debounce: { type: Number, default: 300 } }
  static targets = ["input", "results"]

  connect() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.fetchResults(), this.debounceValue)
  }

  async fetchResults() {
    const q = this.inputTarget.value.trim()
    const resultsTarget = this.resultsTarget
    if (!q) {
      resultsTarget.innerHTML = ""
      // Reload the base content
      try {
        const r = await fetch(this.urlValue, { headers: { "Accept": "text/html" } })
        resultsTarget.innerHTML = await r.text()
      } catch (e) { /* silent */ }
      return
    }
    const url = `${this.urlValue}?q=${encodeURIComponent(q)}`
    try {
      const response = await fetch(url, { headers: { "Accept": "text/html" } })
      resultsTarget.innerHTML = await response.text()
    } catch (e) { /* silent */ }
  }
}
