const state = {
  isRunning: false,
  specification: `
function testAdder() {
  const sut = new Adder(1, 2);
  assert(sut.result === 3);
}

testAdder();`,
  generatedCode: "",
  currentIteration: 0,
  status: null
};

let subscribers = []

function setState(patch) {
  Object.assign(state, patch)
  subscribers.forEach(fn => fn(state))
}

function subscribe(fn) {
  subscribers.push(fn)
  fn(state)
}

function runGeneration() {
  setState({
    isRunning: true,
    status: null,
    generatedCode: "",
    currentIteration: 0
  })

  let count = 0
  const interval = setInterval(() => {
    count++
    setState({ currentIteration: count })

    if (count >= 5) {
      clearInterval(interval)
      setState({
        isRunning: false,
        generatedCode: "// Código generado automáticamente",
        status: "success"
      })
    }
  }, 300)
}


// Inject this from swift
Object.defineProperty(Element.prototype, "onClick", {
  set(handler) {
    this.addEventListener("click", handler)
  }
})
