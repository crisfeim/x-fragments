import Foundation

struct Parser {
    let sourcePath: String
    let outputPath: String

    init(sourcePath: String, outputPath: String) {
      self.sourcePath = sourcePath
      self.outputPath = outputPath
    }

    func parse(_ string: String) throws -> String {
        string
    }
}

class ParserTests {
  static func run() {
    let instance = ParserTests()
    instance.test_parse_parsesImportBlocks()
  }
  
  func test_parse_parsesImportBlocks() {
    _assert(false, "should be true")
  }
}


func _assert(_ condition: Bool, _ description: String? = nil, line: UInt = #line, function: StaticString = #function, file: String = #file) {
  let emoji = condition ? "🟢" : "🔴"
  print(line, emoji, description ?? "", function, file)
  assert(condition)
}