import { Controller } from "@hotwired/stimulus"

// Theme controller: dark / light / system
// Reads preference from localStorage, falls back to system preference.
// Usage: <div data-controller="theme">
//   <button data-action="click->theme#set" data-theme="light">☀️</button>
//   <button data-action="click->theme#set" data-theme="dark">🌙</button>
//   <button data-action="click->theme#set" data-theme="system">💻</button>
export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.applyTheme(this.currentTheme())
    this.highlightActive()
  }

  currentTheme() {
    return localStorage.getItem("ratf-theme") || "system"
  }

  set(event) {
    const theme = event.currentTarget.dataset.theme
    localStorage.setItem("ratf-theme", theme)
    this.applyTheme(theme)
    this.highlightActive()
  }

  applyTheme(theme) {
    if (theme === "system") {
      const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
      document.documentElement.dataset.theme = prefersDark ? "dark" : "light"
    } else {
      document.documentElement.dataset.theme = theme
    }
  }

  highlightActive() {
    const current = this.currentTheme()
    this.buttonTargets.forEach(btn => {
      btn.classList.toggle("active", btn.dataset.theme === current)
    })
  }
}
