import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["detailItem", "toggleButton"];

  // If any details are closed, open them all; otherwise, close them all
  toggleDetails() {
    let set_open = this.hasClosedDetails();
    this.detailItemTargets.forEach((element) => {
      set_open ? element.open = true : element.open = false;
    });
    this.toggleButtonText();
  }

  toggleButtonText() {
    if (this.hasClosedDetails()) {
      this.toggleButtonTarget.textContent = "Expand all";
    } else {
      this.toggleButtonTarget.textContent = "Collapse all";
    }
  }

  hasClosedDetails() {
    return this.detailItemTargets.some((element) => !element.open);
  }
}
