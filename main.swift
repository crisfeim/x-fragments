// === main.swift (compilador + servidor Vapor con style merge) ===

import Foundation

class ComponentCompiler {
    let sourcePath: String
    let outputPath: String

    init(sourcePath: String, outputPath: String) {
      self.sourcePath = sourcePath
      self.outputPath = outputPath
    }

    private var collectedStyles: [String] = []
    private var elementDeclarations: [String] = []

    func compileToFile(injectedScript: String = "") throws {
      let html = try compileToString(injectedScript: injectedScript)
      let fm = FileManager.default
        if !fm.fileExists(atPath: outputPath) {
          try fm.createDirectory(atPath: outputPath, withIntermediateDirectories: true)
        }

      let outputFile = "\(outputPath)/index.html"
      try html.write(toFile: outputFile, atomically: true, encoding: .utf8)
    }

    private func compileToString(injectedScript: String = "") throws -> String {
        var html = try String(contentsOfFile: "\(sourcePath)/index.html", encoding: .utf8)
        html = try injectComponents(into: html)

        let ui = extract(tag: "ui", from: html)
        let actions = extract(tag: "actions", from: html)

        html = remove(tag: "ui", from: html)
        html = remove(tag: "actions", from: html)

        let stateJS = try String(contentsOfFile: "\(sourcePath)/store.js", encoding: .utf8)

        let scriptBlock = """
        <script>
        \(stateJS)

        \(elementDeclarations.joined(separator: "\n"))

        \(actions ?? "")

        subscribe(state => {
        \(ui ?? "")
        });

        \(injectedScript)
        </script>
        """


        if !collectedStyles.isEmpty {
            let styleBlock = "<style>\n\(collectedStyles.joined(separator: "\n"))\n</style>"
            html.append("\n\(styleBlock)")
        }

        return "\(scriptBlock)\n\(html)"
    }

    private func injectComponents(into html: String) throws -> String {
      let fileManager = FileManager.default
      let componentFiles = try fileManager.contentsOfDirectory(atPath: sourcePath)
        .filter { $0.hasSuffix(".html") && $0 != "index.html" }

      var result = html
      elementDeclarations = [] // reset

      for filename in componentFiles {
        let tag = filename.replacingOccurrences(of: ".html", with: "")
        let pattern = "<\(tag)[^>]*></\(tag)>"
        let componentPath = "\(sourcePath)/\(filename)"
        let componentHTML = try String(contentsOfFile: componentPath, encoding: .utf8)

        if let styleBlock = extract(tag: "style", from: componentHTML) {
          collectedStyles.append(styleBlock)
        }

        let variableName = tag
          .split(separator: "-")
          .enumerated()
          .map { i, part in i == 0 ? part.lowercased() : part.capitalized }
          .joined()
        elementDeclarations.append("const \(variableName) = document.querySelector(\"\(tag)\")")

        result = result.replacingOccurrences(of: pattern, with: componentHTML, options: .regularExpression)
      }

      return result
    }

    private func extract(tag: String, from html: String) -> String? {
        let pattern = "<\(tag)[^>]*>([\\s\\S]*?)</\(tag)>"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(html.startIndex..., in: html)
        guard let match = regex.firstMatch(in: html, options: [], range: range),
              let bodyRange = Range(match.range(at: 1), in: html)
        else { return nil }
        return String(html[bodyRange]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func remove(tag: String, from html: String) -> String {
        let pattern = "<\(tag)[^>]*>[\\s\\S]*?</\(tag)>"
        return html.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
    }
}

// === Hot reload script ===

let injectedReloadScript = """
const socket = new WebSocket("ws://localhost:8080/reload");
socket.onmessage = async msg => {
  if (msg.data === "reload") {
    const res = await fetch("/");
    const html = await res.text();
    const doc = document.createElement("html");
    doc.innerHTML = html;
    document.head.replaceWith(doc.querySelector("head"));
    document.body.replaceWith(doc.querySelector("body"));
  }
};
"""

// === File Watcher ===

func startWatching(path: String, onChange: @escaping () -> Void) {
    let fd = open(path, O_EVTONLY)
    let source = DispatchSource.makeFileSystemObjectSource(
        fileDescriptor: fd,
        eventMask: .write,
        queue: DispatchQueue.global()
    )
    source.setEventHandler { onChange() }
    source.setCancelHandler { close(fd) }
    source.resume()
}

let cwd = FileManager.default.currentDirectoryPath
let _ = try! ComponentCompiler(
  sourcePath: "\(cwd)/input",
  outputPath: "\(cwd)/output"
).compileToFile()
