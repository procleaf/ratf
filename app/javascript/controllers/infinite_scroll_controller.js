import { Controller } from "@hotwired/stimulus"

// Infinite scroll: loads next page and appends rows when user approaches bottom.
// Usage: <table data-controller="infinite-scroll" data-infinite-scroll-next-url-value="/jobs?page=2">
//        <tbody data-infinite-scroll-target="body">...</tbody>
//        </table>
export default class extends Controller {
  static values = { nextUrl: String, loading: { type: Boolean, default: false } }
  static targets = ["body", "sentinel"]

  connect() {
    this.observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && this.nextUrlValue && !this.loadingValue) {
          this.loadMore()
        }
      },
      { threshold: 0.1 }
    )
    if (this.hasSentinelTarget) this.observer.observe(this.sentinelTarget)
  }

  disconnect() {
    this.observer?.disconnect()
  }

  async loadMore() {
    this.loadingValue = true
    try {
      const response = await fetch(this.nextUrlValue, { headers: { "Accept": "text/html" } })
      const html = await response.text()
      const parser = new DOMParser()
      const doc = parser.parseFromString(html, "text/html")
      const newRows = doc.querySelectorAll("tbody tr")
      newRows.forEach(row => this.bodyTarget.appendChild(row))
      const nextLink = doc.querySelector("[data-infinite-scroll-next-url]")
      this.nextUrlValue = nextLink?.dataset?.infiniteScrollNextUrl || ""
    } catch (e) { /* silent */ }
    this.loadingValue = false
  }
}
