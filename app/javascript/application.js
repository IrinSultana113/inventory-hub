
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"

const Tab = window.bootstrap?.Tab
const Tooltip = window.bootstrap?.Tooltip

// Initialize Bootstrap tooltips
function initializeTooltips() {
  if (!Tooltip) return

  document
    .querySelectorAll('[data-bs-toggle="tooltip"]')
    .forEach((element) => {
      Tooltip.getOrCreateInstance(element)
    })
}

// Activate inventory tab from URL hash
function activateInventoryTab() {
  const description = document.getElementById("inventory-description")

  if (!description || !Tab) return

  const hash = window.location.hash

  if (!hash) return

  const tabButtons = document.querySelectorAll(
    "#inventoryTabs [data-bs-toggle='tab']"
  )

  const selectedButton = Array.from(tabButtons).find(
    (button) => button.getAttribute("data-bs-target") === hash
  )

  if (selectedButton) {
    Tab.getOrCreateInstance(selectedButton).show()
  }
}

// Hide description when any inventory tab is opened
document.addEventListener("shown.bs.tab", function (event) {
  if (!event.target.closest("#inventoryTabs")) return

  const description = document.getElementById("inventory-description")

  if (description) {
    description.style.display = "none"
  }
})

// Run on page loads
document.addEventListener("turbo:load", function () {
  initializeTooltips()
  activateInventoryTab()
})

document.addEventListener("DOMContentLoaded", function () {
  initializeTooltips()
  activateInventoryTab()
})

// Dispose tooltips before Turbo caches the page
document.addEventListener("turbo:before-cache", () => {
  if (!Tooltip) return

  document
    .querySelectorAll('[data-bs-toggle="tooltip"]')
    .forEach((element) => {
      Tooltip.getInstance(element)?.dispose()
    })
})
