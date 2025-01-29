// app/javascript/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  copy(event) {
    const button = event.currentTarget
    const originalText = button.textContent
    const text = button.dataset.clipboardText

    navigator.clipboard.writeText(text).then(() => {
      button.textContent = "Copied!"
      button.classList.add("bg-green-600")

      setTimeout(() => {
        button.textContent = originalText
        button.classList.remove("bg-green-600")
      }, 2000)
    })
  }
}
