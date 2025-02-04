class SelectImageAreaWidget {
  constructor(el) {
    this.panel = el
    if (this.applicable()) {
      this.addSelectImageAreaLink()
      this.listenForImageViewerStateUpdate()
      this.listenForMultiImageSelectorChanges()
    }
  }

  get itemId() { return this.panel.dataset.id }
  get resourceId() { return this.panel.dataset.resourceId }
  get fullImageUrl() { return this.panel.querySelector(`input[name="item[${this.itemId}][full_image_url]"]`).value }
  get exhibitPath() { return this.panel.closest('form').dataset.exhibitPath }
  get paginationElement() { return this.panel.querySelector('[data-panel-image-pagination]') }
  get paginationThumbnailsElement() { return this.panel.querySelector(".thumbs-list") }
  get paginationCurrentPageElement() { return this.panel.querySelector('[data-current-image]') }
  get iiifCanvasIdElement() { return this.panel.querySelector(`input[name="item[${this.itemId}][iiif_canvas_id]"]`) }
  get iiifImageIdInputElement() { return this.panel.querySelector(`input[name="item[${this.itemId}][iiif_image_id]`) }
  get iiifViewerConfigElement() { return this.panel.querySelector(`input[name="item[${this.itemId}][iiif_initial_viewer_config]"]`) }
  get fullImageUrlInputElement() { return this.panel.querySelector(`input[name="item[${this.itemId}][full_image_url]"]`) }
  get selectImageAreaLinkElement() { return this.panel.querySelector('.select-image-area') }
  get thumbnailImageUrlInputElement() { return this.panel.querySelector(`input[name="item[${this.itemId}][thumbnail_image_url]"]`) }
  get thumbnailImageElement() { return this.panel.querySelector('.img-thumbnail') }

  applicable() {
    return !this.isLocalImage() && !this.selectImageAreaLinkElement
  }

  isLocalImage() {
    return this.resourceId && /^\d+-\d+$/.test(this.resourceId)
  }

  addSelectImageAreaLink() {
    const linkElement = this.createSelectImageAreaLink()
    this.paginationElement.parentNode.insertBefore(linkElement, this.paginationElement)
  }

  buildSelectImageAreaUrl() {
    return `${this.exhibitPath}/select_image_area/${this.resourceId}?${this.buildUrlParams().toString()}`
  }

  updateSelectImageAreaLink() {
    this.selectImageAreaLinkElement.href = this.buildSelectImageAreaUrl()
  }

  createSelectImageAreaLink() {
    const linkElement = document.createElement('a')
    Object.assign(linkElement, {
      className: "select-image-area",
      href: this.buildSelectImageAreaUrl(),
      innerHTML: 'Select image area'
    })
    linkElement.setAttribute('data-blacklight-modal', 'trigger')
    return linkElement
  }

  listenForImageViewerStateUpdate() {
    this.panel.addEventListener('imageViewerStateUpdate', (event) => {
      this.handleImageViewerStateUpdate(event)
    })
  }

  listenForMultiImageSelectorChanges() {
    // These are changes to the hidden `iiif_canvas_id` field that Spotlight's
    // multi-image selector makes.
    this.iiifCanvasIdElement.addEventListener('change', (event) => {
      this.resetIiifViewerConfig()
      this.updateSelectImageAreaLink()
    })
  }

  handleImageViewerStateUpdate(event) {
    const { viewers, windows, iiif_images, canvas_index } = event.detail
    const viewerKey = Object.keys(viewers)[0]
    const canvasId = windows[viewerKey]['canvasId']
    const iiifViewerConfig = JSON.stringify(viewers[viewerKey])
    const iiifImageUrl = iiif_images[0]
    const thumbnailUrl = iiifImageUrl.replace('full', '!100,100')

    this.iiifCanvasIdElement.value = canvasId
    this.iiifViewerConfigElement.value = iiifViewerConfig
    this.fullImageUrlInputElement.value = iiifImageUrl
    this.thumbnailImageUrlInputElement.value = thumbnailUrl
    this.thumbnailImageElement.src = `${thumbnailUrl}?${new Date().getTime()}`
    this.setCurrentPaginationImage(canvas_index)
    this.updateSelectImageAreaLink()
  }

  setCurrentPaginationImage(index) {
    if (this.paginationCurrentPageElement) {
      const thumbIndex = index - 1
      const previousThumb = this.paginationThumbnailsElement.querySelector(".active")
      const newThumb = this.paginationThumbnailsElement.querySelector(`[data-index="${thumbIndex}"]`)

      this.paginationCurrentPageElement.innerText = index
      previousThumb?.classList.remove('active')
      newThumb.classList.add('active')
      this.iiifImageIdInputElement.value = newThumb.querySelector("[data-image-id]").dataset.imageId
    }
  }

  buildUrlParams() {
    // Note: These are checks for the literal string "undefined" coming from the data.
    return new URLSearchParams({
      form_id: this.panel.id,
      item_id: this.itemId,
      ...(this.iiifCanvasIdElement.value !== "undefined" && { canvas_id: this.iiifCanvasIdElement.value }),
      ...(this.hasIiifViewerConfig() && { iiif_initial_viewer_config: this.iiifViewerConfigElement.value })
    })
  }

  hasIiifViewerConfig() {
    return this.iiifViewerConfigElement?.value !== "undefined" && this.iiifViewerConfigElement?.value !== undefined
  }

  resetIiifViewerConfig() {
    this.iiifViewerConfigElement.value = "undefined"
  }
}

class SelectImageArea {
  static init() {
    const sirTrevorEditor = SirTrevor?.config.instances[0]
    if (!sirTrevorEditor) return

    const initializer = new SelectImageArea(sirTrevorEditor)
    initializer.setup()
  }

  constructor(editor) {
    this.editor = editor
    this.blockSelector = '[data-behavior="nestable"]'
    this.panelSelector = ".field"
  }

  setup() {
    this.initializeExistingBlocks()
    this.handleNewBlocks()
    this.handleNewPanelsInExistingBlocks()
  }

  initializeExistingBlocks() {
    document.querySelectorAll(this.blockSelector).forEach((block) => this.createSelectImageAreaWidgets(block))
  }

  handleNewBlocks() {
    this.editor.mediator.on('block:created', (e) => {
      this.addSirTrevorPanelChangeHandler(e.el)
    })
  }

  handleNewPanelsInExistingBlocks() {
    this.addSirTrevorPanelChangeHandler(document)
  }

  createSelectImageAreaWidgets(blockElement) {
    blockElement.querySelectorAll(this.panelSelector).forEach(panel => new SelectImageAreaWidget(panel))
  }

  addSirTrevorPanelChangeHandler(element) {
    // Spotlight's Sir Trevor blocks use jQuery events.
    $(element).find(this.blockSelector).on('change', (block) => {
      this.createSelectImageAreaWidgets(block.target)
    })
  }
}

Spotlight.onLoad(() => SelectImageArea.init())
