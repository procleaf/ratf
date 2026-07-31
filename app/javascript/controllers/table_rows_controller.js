import { Controller } from "@hotwired/stimulus"

// Click table rows to navigate to the record's show page
// Usage: <table data-controller="table-rows">
//   <tr data-table-rows-target="row" data-href="/jobs/1">
export default class extends Controller {
  static targets = ["row"]

  navigate(event) {
    const row = event.currentTarget
    const href = row.dataset.href
    if (href && !event.target.closest("a, button, input, select, .btn")) {
      window.location = href
    }
  }
}
