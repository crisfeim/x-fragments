# Fragments

Small exploration of creating interactive components in vanilla HTML, JS and CSS.

## Motiviation

Generating and embedding interactive components in articles without *npm*, reactive libraries, or any heavy modern frontend stack.

## Design

A **minimal declarative component system** powered by:

- HTML files representing components
- A single `store.js` file as the reactive store
- A Swift compiler that:
  - Gathers all `<style>` blocks into one
  - Extracts UI and event logic from `<script>`
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

Then run `swiftc main.swift` and import the output `output/index.html` into your article (with an iframe or an embedding system)
