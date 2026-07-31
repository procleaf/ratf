import { Controller } from "@hotwired/stimulus"

// Inline edit: click a cell → turns into a form → submits via fetch → replaces content.
// Usage: <td data-controller="inline-edit" data-inline-edit-url-value="/jobs/1" data-inline-edit-field-value="name">
//        <span data-inline-edit-target="display">Job Name</span>
//        <form data-inline-edit-target="form" style="display:none">...</form>
//        </td>
export default class extends Controller {
  static values = { url: String, field: String }
  static targets = ["display", "form", "input"]

  connect() {
    this.displayTarget.addEventListener("click", () => this.edit())
    this.formTarget.addEventListener("submit", (e) => { e.preventDefault(); this.save() })
    this.formTarget.addEventListener("keydown", (e) => {
      if (e.key === "Escape") this.cancel()
    })
  }

  edit() {
    this.displayTarget.style.display = "none"
    this.formTarget.style.display = "inline"
    if (this.hasInputTarget) this.inputTarget.focus()
  }

  cancel() {
    this.displayTarget.style.display = "inline"
    this.formTarget.style.display = "none"
  }

  async save() {
    const formData = new FormData(this.formTarget)
    const csrf = document.querySelector("meta[name='csrf-token']")?.content
    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: { "X-CSRF-Token": csrf, "Accept": "application/json" },
        body: formData
      })
      if (response.ok) {
        const data = await response.json()
        this.displayTarget.textContent = data[this.fieldValue] || "Updated"
        this.cancel()
      }
    } catch (e) { /* silent */ }
  }
}
