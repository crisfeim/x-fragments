# Fragments

Small exploration of generating interactive components in vanilla HTML, JS and CSS.

## Motiviation

Embedding interactive components in articles without npm, reactive libraries, or any heavy modern frontend stack.

## Design

A **minimal declarative component system** powered by:

- HTML files representing components
- A single `state.js` file as the reactive store
- `<ui>` and `<actions>` blocks for logic and event binding
- A Swift compiler that:
  - Injects components where used by tag
  - Gathers all `<style>` blocks into one
  - Extracts UI and event logic from `<script ui>` and `<script actions>`
  - Outputs a single `index.html` — fully static and standalone


## Example usage

Given this folder structure:

```bash
|- index.html
|- state.js
|- counter-button.html
```

In your `index.html` file:

```html
<counter-button></counter-button>

<ui>
  counterButton.textContent = `Counter: ${state.count}`
</ui>

<actions>
  counterButton.addEventListener("click", () => {
    setState({ count: state.count + 1 })
  })
</actions>

Then run `swiftc main.swift`.
