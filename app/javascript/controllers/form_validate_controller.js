import { Controller } from "@hotwired/stimulus"

// Client-side form validation: validates on blur/submit, shows errors inline.
// Usage: <form data-controller="form-validate">
//        <input data-form-validate-required="true" data-form-validate-pattern="^[a-z]+$">
//        </form>
export default class extends Controller {
  static values = { submitting: { type: Boolean, default: false } }

  connect() {
    this.element.addEventListener("submit", (e) => {
      if (!this.validate()) e.preventDefault()
    })
  }

  validate() {
    let valid = true
    this.clearErrors()
    this.element.querySelectorAll("[data-form-validate-required]").forEach(el => {
      const val = el.value.trim()
      if (!val) {
        this.showError(el, "This field is required")
        valid = false
      }
    })
    this.element.querySelectorAll("[data-form-validate-pattern]").forEach(el => {
      const pattern = el.dataset.formValidatePattern
      const val = el.value.trim()
      if (val && pattern && !new RegExp(pattern).test(val)) {
        this.showError(el, `Invalid format. Expected: ${pattern}`)
        valid = false
      }
    })
    return valid
  }

  showError(el, message) {
    el.classList.add("field-error")
    const span = document.createElement("span")
    span.className = "field-error-msg"
    span.textContent = message
    el.parentNode.appendChild(span)
  }

  clearErrors() {
    this.element.querySelectorAll(".field-error").forEach(el => el.classList.remove("field-error"))
    this.element.querySelectorAll(".field-error-msg").forEach(el => el.remove())
  }
}
