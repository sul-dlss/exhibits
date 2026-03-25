import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  updateTypeAhead() {
    const hiddenElements = document.querySelectorAll(`:not(${this.element.value})[data-behavior="site-search-type"]`)
    hiddenElements.forEach(he => {
      he.style.display = 'none';
    })
    document.querySelector(this.element.value).style.display = 'block';
  }
}