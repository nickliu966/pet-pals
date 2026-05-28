// Animate selected Turbo Stream actions.
// Keep global append/remove animations,
// but only animate replace for walk participant list updates.

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

  const shouldAnimate = targetId.includes("participant_list")

  if (!shouldAnimate) return

  const originalRender = event.detail.render

  event.detail.render = (streamElement) => {
    originalRender(streamElement)

    const target = document.getElementById(targetId)
    if (!target) return

    target.classList.add("soft-replace-in")

    target.addEventListener(
      "animationend",
      () => target.classList.remove("soft-replace-in"),
      { once: true }
    )
  }
})
