import { Controller } from "@hotwired/stimulus"

// Star/unstar toggle via fetch API (no page reload)
// Usage: <button data-controller="favorite" data-favorite-test-case-id="42" data-favorite-starred="true">
export default class extends Controller {
  static values = { testCaseId: Number, starred: Boolean }

  connect() {
    this.updateIcon()
  }

  toggle() {
    const url = `/favorites/toggle?test_case_id=${this.testCaseIdValue}`

    fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "application/json"
      }
    })
    .then(r => r.json())
    .then(data => {
      this.starredValue = data.starred
      this.updateIcon()
    })
  }

  updateIcon() {
    this.element.querySelector(".star-icon").textContent = this.starredValue ? "⭐" : "☆"
    this.element.querySelector(".star-label").textContent = this.starredValue ? "Starred" : "Star"
  }
}
