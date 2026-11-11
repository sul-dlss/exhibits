import { Controller } from "@hotwired/stimulus"

let uuid = 0

// Attached to the full text highlights inside a document's metadata <dd>.
// Makes the <dd> collapsible (toggled by its <dt>), and moves the
// "Search for ... in document text" link into its own <dt>.
export default class extends Controller {
  connect() {
    const dd = this.element.closest("dd")
    const dt = dd?.previousElementSibling
    // Skip if already set up (e.g. a page restored from the Turbo cache)
    if (!dt || dt.tagName !== "DT" || dd.classList.contains("collapse")) return

    dd.classList.add("collapse")
    if (!dd.id) dd.id = `full-text-highlight-${++uuid}`

    dt.textContent = dt.textContent.trim().replace(/:$/, "")
    dt.classList.add("show-hide-toggle")
    dt.dataset.bsToggle = "collapse"
    dt.dataset.bsTarget = `#${dd.id}`

    const link = this.element.querySelector("a.prepared-search-link")
    if (!link) return

    const linkContainer = document.createElement("dt")
    linkContainer.className = "prepared-search-container"
    linkContainer.append(link)
    const spacer = document.createElement("dd")
    spacer.className = "w-100"
    dt.before(linkContainer, spacer)

    // Without any highlights, only the link is worth showing
    if (!this.element.querySelector("p")) {
      dt.remove()
      dd.remove()
    }
  }
}
