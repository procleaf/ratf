import { Controller } from "@hotwired/stimulus"

// Locale (language) controller: English / Chinese
// Reads preference from localStorage, sets via URL param.
export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.highlightActive()
  }

  currentLocale() {
    return localStorage.getItem("ratf-locale") || "en"
  }

  set(event) {
    const locale = event.currentTarget.dataset.locale
    localStorage.setItem("ratf-locale", locale)
    // Reload with locale param to trigger server-side switch
    const url = new URL(window.location)
    url.searchParams.set("locale", locale)
    window.location = url.toString()
  }

  highlightActive() {
    const current = this.currentLocale()
    this.buttonTargets.forEach(btn => {
      btn.classList.toggle("active", btn.dataset.locale === current)
    })
  }
}
