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


func _assert(_ condition: Bool, _ description: String? = nil, line: UInt = #line, function: StaticString = #function, file: String = #file) {
  let emoji = condition ? "🟢" : "🔴"
  print(line, emoji, description ?? "", function, file)
  assert(condition)
}