// Animate Turbo Stream remove/append/replace actions.
// Based on the course pattern using turbo:before-stream-render.

document.addEventListener("turbo:before-stream-render", (event) => {
  if (event.target.action !== "remove") return

  const target = document.getElementById(event.target.target)
  if (!target) return

  const originalRender = event.detail.render

  event.detail.render = (streamElement) => {
    let removed = false

    const removeTarget = () => {
      if (removed) return
      removed = true
      originalRender(streamElement)
    }

    target.classList.add("fade-out")

    target.addEventListener("animationend", removeTarget, { once: true })

    // Fallback: still remove even if animationend does not fire.
    setTimeout(removeTarget, 500)
  }
})

document.addEventListener("turbo:before-stream-render", (event) => {
  if (event.target.action !== "append") return

  const target = document.getElementById(event.target.target)
  if (!target) return

  const startCount = target.children.length
  const originalRender = event.detail.render

  event.detail.render = (streamElement) => {
    originalRender(streamElement)

    Array.from(target.children)
      .slice(startCount)
      .forEach((child) => child.classList.add("fade-in"))
  }
})

document.addEventListener("turbo:before-stream-render", (event) => {
  if (event.target.action !== "replace") return

  const targetId = event.target.target
  const originalRender = event.detail.render

  event.detail.render = (streamElement) => {
    originalRender(streamElement)

    const target = document.getElementById(targetId)
    if (target) target.classList.add("highlight")
  }
})
