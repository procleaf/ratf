import { Controller } from "@hotwired/stimulus"

// Bulk select checkboxes with select-all / deselect-all toggle
// Usage:
//   <div data-controller="bulk-select"
//        data-bulk-select-model-value="Job"
//        data-bulk-select-action-url-value="<%= bulk_operations_path %>">
//     <input type="checkbox" data-bulk-select-target="checkbox" data-action="bulk-select#update" value="1">
//     <button data-action="bulk-select#toggleAll">Select All</button>
//     <form data-bulk-select-target="form">...</form>
//   </div>
export default class extends Controller {
  static targets = ["checkbox", "form", "selectAll"]
  static values = { model: String, actionUrl: String }

  connect() {
    this.update()
  }

  update() {
    const form = this.hasFormTarget ? this.formTarget : null
    const checked = this.checkboxTargets.filter(cb => cb.checked)
    if (form) {
      form.style.display = checked.length > 0 ? "" : "none"
      const idsField = form.querySelector("input[name='ids']")
      if (idsField) {
        idsField.value = checked.map(cb => cb.value).join(",")
      }
    }
    // Update select-all button text
    if (this.hasSelectAllTarget) {
      const all = this.checkboxTargets.length
      this.selectAllTarget.textContent = checked.length === all ? "Deselect All" : "Select All"
    }
    // Update model field
    if (form) {
      const modelField = form.querySelector("input[name='model']")
      if (modelField && this.hasModelValue) {
        modelField.value = this.modelValue
      }
    }
  }

  toggleAll() {
    const checked = this.checkboxTargets.filter(cb => cb.checked)
    const selectAll = checked.length !== this.checkboxTargets.length
    this.checkboxTargets.forEach(cb => { cb.checked = selectAll })
    this.update()
  }

  submit(event) {
    const checked = this.checkboxTargets.filter(cb => cb.checked)
    if (checked.length === 0) {
      event.preventDefault()
      alert("No records selected.")
    }
  }
}
