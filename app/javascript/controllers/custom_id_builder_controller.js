
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "preview", "template"]

  connect() {
    this.updateElementInputs()
    this.updatePreview()

    this.handleDocumentDragOver = this.handleDocumentDragOver.bind(this)
    this.handleDocumentDrop = this.handleDocumentDrop.bind(this)

    document.addEventListener("dragover", this.handleDocumentDragOver)
    document.addEventListener("drop", this.handleDocumentDrop)
  }

  disconnect() {
    document.removeEventListener("dragover", this.handleDocumentDragOver)
    document.removeEventListener("drop", this.handleDocumentDrop)
  }

  add(event) {
    const currentCount =
    this.listTarget.querySelectorAll("[data-id-element]").length

      if (currentCount >= 10) {
        alert("You can add a maximum of 10 elements.")
      return
      }
    const type = event.currentTarget.dataset.type

    const template = this.templateTarget.content.cloneNode(true)
    const element = template.querySelector("[data-id-element]")

    element.dataset.elementType = type
    element.setAttribute("draggable", "true")
    element.setAttribute(
      "data-action",
      "dragstart->custom-id-builder#dragStart dragend->custom-id-builder#dragEnd"
    )

    element.querySelector("[data-element-type]").textContent =
      this.elementName(type)

    element.querySelector("[data-type-input]").value = type

    const valueInput = element.querySelector("[data-value-input]")
    const formatInput = element.querySelector("[data-format-input]")

    if (type === "fixed_text") {
      valueInput.value = "ITEM-"
    }

    const formats = {
      sequence: "D4",
      random_20bit: "D7",
      random_32bit: "D10",
      random_6_digit: "D6",
      random_9_digit: "D9"
    }

    if (formats[type]) {
      formatInput.value = formats[type]
    }

    this.listTarget.appendChild(element)

    this.updateElementInputs()
    this.updatePreview()
  }

  remove(event) {
    event.currentTarget.closest("[data-id-element]").remove()
    this.updatePreview()
  }

  dragStart(event) {
    this.draggedElement = event.currentTarget
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", "move")
    this.draggedElement.classList.add("opacity-50")
  }

  dragEnd() {
    if (this.draggedElement) {
      this.draggedElement.classList.remove("opacity-50")
    }

    this.draggedElement = null
    this.updatePreview()
  }

  handleDocumentDragOver(event) {
    if (this.draggedElement) {
      event.preventDefault()
    }
  }

  handleDocumentDrop(event) {
    if (!this.draggedElement) return

    if (!this.listTarget.contains(event.target)) {
      this.draggedElement.remove()
      this.draggedElement = null

      this.updateElementInputs()
      this.updatePreview()
    }
  }
  allowDrop(event) {
    event.preventDefault()
  }
  dropInside(event) {
    event.preventDefault()
    event.stopPropagation()

    if (!this.draggedElement) return

    const targetElement = document
      .elementFromPoint(event.clientX, event.clientY)
      ?.closest("[data-id-element]")

    if (!targetElement || targetElement === this.draggedElement) {
      this.listTarget.appendChild(this.draggedElement)
    } else {
      const position = targetElement.getBoundingClientRect()
      const shouldInsertBefore =
        event.clientY < position.top + position.height / 2

      if (shouldInsertBefore) {
        this.listTarget.insertBefore(this.draggedElement, targetElement)
      } else {
        this.listTarget.insertBefore(
          this.draggedElement,
          targetElement.nextSibling
        )
      }
    }

    this.draggedElement.classList.remove("opacity-50")
    this.draggedElement = null

    this.updateElementInputs()
    this.updatePreview()
  }

  updateElementInputs() {
    this.listTarget.querySelectorAll("[data-id-element]").forEach((element) => {
      const type = element.dataset.elementType

      const valueContainer = element.querySelector("[data-fixed-text-input]")
      const formatContainer = element.querySelector("[data-number-format-input]")

      if (valueContainer) {
        valueContainer.hidden = type !== "fixed_text"
      }

      if (formatContainer) {
        formatContainer.hidden = ![
          "sequence",
          "random_20bit",
          "random_32bit",
          "random_6_digit",
          "random_9_digit"
        ].includes(type)
      }
    })
  }

  
  updatePreview() {
    const elements = this.listTarget.querySelectorAll("[data-id-element]")

    let preview = ""
    let hasInvalidFormat = false

    elements.forEach((element) => {
      const type = element.dataset.elementType

      if (type === "fixed_text") {
        preview += element.querySelector("[data-value-input]").value

      } else if (
        ["sequence", "random_20bit", "random_32bit",
        "random_6_digit", "random_9_digit"].includes(type)
      ) {
        const formatInput = element.querySelector("[data-format-input]")
        const format = formatInput.value.trim()

        if (!this.isValidNumberFormat(format)) {
          formatInput.classList.add("is-invalid")
          hasInvalidFormat = true
          return
        }

        formatInput.classList.remove("is-invalid")

        if (type === "sequence") {
          preview += this.exampleNumber(format, 1)
        } else {
          preview += this.exampleRandom(type)
        }

      } else if (type === "guid") {
        preview += "550e8400-e29b-41d4-a716-446655440000"

      } else if (type === "date") {
        const today = new Date()

        const year = today.getFullYear()
        const month = String(today.getMonth() + 1).padStart(2, "0")
        const day = String(today.getDate()).padStart(2, "0")

        preview += `${year}${month}${day}`

      } else if (type === "time") {
        const now = new Date()

        const hours = String(now.getHours()).padStart(2, "0")
        const minutes = String(now.getMinutes()).padStart(2, "0")
        const seconds = String(now.getSeconds()).padStart(2, "0")

        preview += `${hours}${minutes}${seconds}`
      }
    })

    if (hasInvalidFormat) {
      this.previewTarget.textContent =
        "Invalid number format! Use D4, D6 or X5."
      return
    }

    this.previewTarget.textContent =
     preview || "Add elements to preview your ID"
    }

  elementName(type) {
    const names = {
      fixed_text: "Fixed Text",
      sequence: "Sequence",
      random_20bit: "20-bit Random",
      random_32bit: "32-bit Random",
      random_6_digit: "6-digit Random",
      random_9_digit: "9-digit Random",
      guid: "GUID",
      date: "Date",
      time: "Time"
    }

    return names[type]
  }


  isValidNumberFormat(format) {
    return /^[DX][1-9][0-9]*$/.test(format)
  }

  
  exampleNumber(format, number) {
    const type = format[0]
    const length = parseInt(format.slice(1), 10)

    const exampleValue = type === "X" ? 255 : number

    return exampleValue.toString(type === "X" ? 16 : 10)
      .toUpperCase()
      .padStart(length, "0")
  }


  exampleRandom(type) {
    const examples = {
      random_20bit: "1234567",
      random_32bit: "1234567890",
      random_6_digit: "123456",
      random_9_digit: "123456789"
    }

    return examples[type]
  }
}
