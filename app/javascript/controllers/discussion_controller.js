
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["posts"]

  static values = {
    url: String,
    lastId: Number
  }

  connect() {
    this.poll()
    this.timer = setInterval(() => this.poll(), 3000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  async poll() {
    if (this.polling) return

    this.polling = true

    try {
      const url = `${this.urlValue}?after_id=${this.lastIdValue}`

      const response = await fetch(url, {
        headers: {
          Accept: "application/json"
        }
      })

      if (!response.ok) return

      const posts = await response.json()

      posts.forEach(post => this.appendPost(post))

    } catch (error) {
      console.error("Discussion polling failed:", error)

    } finally {
      this.polling = false
    }
  }

  appendPost(post) {
    if (post.id <= this.lastIdValue) return

    const card = document.createElement("div")
    card.className = "card mb-3"
    card.dataset.postId = post.id

    const cardBody = document.createElement("div")
    cardBody.className = "card-body"

    const header = document.createElement("div")
    header.className = "d-flex justify-content-between align-items-center"

    const author = document.createElement("a")
    author.href = `/users/${post.user_id}`
    author.textContent = post.username

    const time = document.createElement("small")
    time.className = "text-muted"
    time.textContent = post.created_at

    header.append(author, time)

    const body = document.createElement("div")
    body.className = "mt-2"
    body.innerHTML = post.body

    cardBody.append(header, body)
    card.append(cardBody)

    const emptyMessage = this.postsTarget.querySelector(
      "#no-discussion-posts"
    )

    if (emptyMessage) {
      emptyMessage.remove()
    }

    this.postsTarget.append(card)

    this.lastIdValue = post.id
  }
}
