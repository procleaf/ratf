import { Controller } from "@hotwired/stimulus"

// Enhanced confirm dialog
// Usage: <a data-controller="confirm" data-confirm-message="Are you sure?" data-action="click->confirm#confirm" href="...">
export default class extends Controller {
  confirm(event) {
    if (!window.confirm(this.element.dataset.confirmMessage || "Are you sure?")) {
      event.preventDefault()
    }
  }
}
