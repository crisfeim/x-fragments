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


## Wishlist

### Recursive components

```js
// index.html
@import(status-indicator)
// status-indicator.html
@import(success-indicator)
@import(failure-indicator)
```

`index.html` should output:

```html
<div class="success-indicator">...</div>
<div class="failure-indicator">...</div>
```

### Standalone component generation

```bash
$ fragments -b /components/component.html
Generated "component.html" in "/dist/component.html"
```

### Injected identity within component scope

```html
<!-- my-component.html --->
<script>
(self | this | me).styles.opacity = 0.5
</script>
```

Outputs:

```html
<!-- my-component.html --->
<div id="my-component"> ... </div>
<script>
const myComponent = documents.getElementById('my-component')
myComponent.styles.opacity = 0.5
</script>
```

### Passing reactive props

```html
<!-- index.html -->
@import(activity-indicator, { "isRunning" : state.isRunning })
```

```html
<!-- activity-indicator.html -->
@Prop(isRunning)

<div class="spinner"></div>
<script>
console.log(isRunning)
</script>

```

Outputs:

```html
<!-- index.html -->
<div id="activity-indicator"><div class="spinner"></div></div>

<script>
console.log(state.isRunning)
</script>
```

But for simple components intended to work as an embedded widget in my articles, I guess it's okay to subscribe to state directly within the component:

```js
<!-- activity-indicator.html -->
<script>
subscribe(state => {
self.style.opacity = state.isRunning ? 1 : 0
})
</script>
```

So not sure how useful this would be for my use-case.

### Inject imported components as javascript elements

```html
<!-- index.html -->
@import(activity-indicator)

<script>
activityIndicator.styles.opacity = 0
</script>
```

Output:

```html
<!-- index.html -->

<div id="activity-indicator">
<div class="spinner">...</div>
</div>

<script>
const activityIndicator = document.getElementById('activity-indicator')
activityIndicator.styles.opacity = 0
</script>
```

### Injected subscription in scope within specific `<script>` tag:

```html
@activity-indicator()

<script id="subcriptions">
activityIndicator.styles.opacity = state.isRuning ? 1 : 0
</script>
```

Outputs:

```html
<div id="hash-123" class="spinner>...</div>

<script>
let activityIndicator = document.getElementById('hash-123')
subscribe(state => {
activityIndicator.style.opacity = state.isRunning ? 1 : 0
})
</script>
```

### Local state and better syntax for reactivity declarations

```html
<!-- my-component.html -->
// Constant with value:
@Let(adderSpecs, "function test() { ... }"

// Constant with no value (to be provided externally):
@Let(adder)

// Computed var:
@Var(isRunningStr, isRunning ? 'running' : 'not running')

@State(isRunning, false)
@State(currentIteration, 0)
@State(generatedCode, null)
@State(runResult, null)
@State(specification, adderSpecs)

// Imports with camelCased file name:
@runButton(onClick: run)

@binding() {
runButton.styles.opacitiy = isRunning ? 1 : 0
}

@run() { 
this.generatedCode = "hello world" 
}

// Alternatively, using scripts tags so we don't lose syntax highlighting):
<script id="ui-bindings">
runButton.styles.opacity = isRunning ? 1 : 0
</script>

<script id="methods">
run() { this.generatedCode = "hello world" }
</script>
```

Compiles to:

```js
const myComponent_hash123_consts = {
adderSpecs: `function test() { ... }`,
adder: null,
}

let myComponent_hash123_subscribers = []

const myComponent_hash123_state = 	{
isRunning: false,
currentIteration: 0,
generatedCode: null,
runResult: null
specification: `function test() { ... }`,
};

function myComponent_hash123_setState(patch) {
Object.assign(myComponent_state, patch)
myComponent_subscribers.forEach(fn => fn(myComponent_state))
}

function myComponent_hash123_subscribe(fn) {
myComponent_subscribers.push(fn)
fn(myComponent_state)
}

const myComponent_hash123_run = () => {
myComponent_hash123_setState({ generatedCode: 'hello world' })
}

const myComponent_hash123_isRunningStr = () => {
return myComponent_hash123_state.isRunning ? 'running' : 'not running'
}

```
  
If compiled as standalone, has could be potentially omitted.