import Foundation

class ComponentCompiler {
    let sourcePath: String
    let outputPath: String

    init(sourcePath: String, outputPath: String) {
      self.sourcePath = sourcePath
      self.outputPath = outputPath
    }

    private var elementDeclarations: [String] = []

    func compileToFile() throws {
      let html = try compileToString()
      let fm = FileManager.default
        if !fm.fileExists(atPath: outputPath) {
          try fm.createDirectory(atPath: outputPath, withIntermediateDirectories: true)
        }

      let outputFile = "\(outputPath)/index.html"
      try html.write(toFile: outputFile, atomically: true, encoding: .utf8)
    }

    private func compileToString() throws -> String {
        var html = try String(contentsOfFile: "\(sourcePath)/index.html", encoding: .utf8)
        html = try injectComponents(into: html)

        var scriptBlock = extract(tag: "script", from: html) ?? ""
        html = remove(tag: "script", from: html)

        let stateJS = try String(contentsOfFile: "\(sourcePath)/store.js", encoding: .utf8)

        scriptBlock = """
        <script>
        \(stateJS)
        \(elementDeclarations.joined(separator: "\n"))
        \(scriptBlock)
        </script>
        """

        return "\(html)\n\(scriptBlock)"
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

let cwd = FileManager.default.currentDirectoryPath
let _ = try! ComponentCompiler(
  sourcePath: "\(cwd)/input",
  outputPath: "\(cwd)/output"
).compileToFile()

Server(port: 4000, requestHandler: { request in
  if request.path == "" {
    return Response(statusCode: 200, contentType: "text/html", body: .text("hello world"))
  } else {
    return Response(statusCode: 400, contentType: "text/html", body: .text("Not fund"))
  }

}).run()
