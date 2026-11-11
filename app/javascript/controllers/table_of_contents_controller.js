import { Controller } from "@hotwired/stimulus"

// Keeps the table of contents toggle label in sync with the collapse state
export default class extends Controller {
  static targets = ["label"]

  show() {
    this.labelTarget.textContent = "Hide"
  }

  hide() {
    this.labelTarget.textContent = "Show"
  }
}
