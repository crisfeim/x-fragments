import Foundation

let cwd = FileManager.default.currentDirectoryPath
let inputPath = "\(cwd)/alpinejs"
let outputPath = "\(cwd)/output"
let contents = try! String(contentsOfFile: "\(inputPath)/index.html", encoding: .utf8)

ParserTests.run()
Server(port: 4000, requestHandler: { request in

  if request.path == "" {
    let index = try! Parser(
      sourcePath: inputPath,
    outputPath: outputPath
    ).parse(contents)
    
    return Response(statusCode: 200, contentType: "text/html", body: .text(index))
  } else {
    return Response(statusCode: 400, contentType: "text/html", body: .text("Not fund"))
  }

}).run()