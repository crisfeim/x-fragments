import Foundation
import RegexBuilder

struct Parser {
  func parse(_ string: String) -> String {
    string
  }
  
  func parseImports(_ string: String) -> [String] {
    let importPattern = Regex {
      "@import("
      Capture {
        OneOrMore {
          NegativeLookahead { ")" }
          CharacterClass.any
        }
      }
      ")"
    }
    
    let matches = string.matches(of: importPattern)
    
    let importedComponents = matches.map { match in
      String(match.output.1)
    }
    
    return importedComponents
  }
}

struct Renderer {
  let sourcesPath: String
  let parser = Parser()
  
  func render(_ filename: String) throws -> String {
  }
}

class TestSuite {
  static func run() {
    ParserTests.run()
    RendererTests.run()
  }
}

class ParserTests {
  static func run() {
    let instance = ParserTests()
    do {
      try instance.test_parse_parsesImports()
      
    } catch {
      print(error)
    }
  }
  
  func test_parse_parsesImports() throws {
    let string = """
    @import(myComponent)
    
    hello world
    """
    let sut = Parser()
    let result = sut.parseImports(string)
    _assert(result == ["myComponent"])
  }
}

class RendererTests {
  static func run() {
    do {
      let instance = RendererTests()
      try instance.test_render_rendersImports()
    } catch {
      print(error)
    }
  }
  
  func test_render_rendersImports() throws {
    let cwd = FileManager.default.currentDirectoryPath
    let sourcesPath = "\(cwd)/tests"
    let sut = Renderer(sourcesPath: sourcesPath)
    let rendered = try sut.render("component1.html")
    let expected = """
    component 1 contents
    component 2 contents
    """
    assertEqual(rendered, expected)
  }
}

func _assert(_ condition: Bool, _ description: String? = nil, line: UInt = #line, function: StaticString = #function, file: String = #file) {
  let emoji = condition ? "🟢" : "🔴"
  print(line, emoji, description ?? "", function, file)
  assert(condition)
}

func assertEqual<T: Equatable>(_ a: T, _ b: T, _ description: String? = nil, line: UInt = #line, function: StaticString = #function, file: String = #file) {
  dump(a)
  dump(b)
  _assert(a == b, description, line: line, function: function)
}