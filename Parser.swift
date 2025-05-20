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

