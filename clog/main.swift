//
//  main.swift
//  clog
//
//  Created by Tyler Hall on 10/31/21.
//

import Cocoa
import ArgumentParser

struct CLOGOptions: ParsableArguments {
    @Flag(help: "List files matching the catalog number.")
    var list = false

    @Argument(help: "The catalog index to search for.")
    var catalogIndex: String
}

let options = CLOGOptions.parseOrExit()
var catalogIndex = options.catalogIndex

let range = catalogIndex.nsRange(from: catalogIndex.startIndex..<catalogIndex.endIndex)
let regex1 = try! NSRegularExpression(pattern: "^[a-zA-Z]{3}[0-9]+$", options: .init())
let regex2 = try! NSRegularExpression(pattern: "^[a-zA-Z]{3}[0-9]+[zZ]$", options: .init())

if regex1.numberOfMatches(in: catalogIndex, options: .init(), range: range) == 1 {
    Common.shared.findCatalogFiles(catalogIndex: catalogIndex, fullText: false)
} else if regex2.numberOfMatches(in: catalogIndex, options: .init(), range: range) == 1 {
    catalogIndex = String(catalogIndex.dropLast())
    Common.shared.findCatalogFiles(catalogIndex: catalogIndex, fullText: true)
}

guard let query = Common.shared.query else {
    exit(0)
}

while !query.isStarted || query.isGathering {
    Thread.sleep(forTimeInterval: 0.01)
}

var matchingFileURLs = [URL]()
for result in query.results {
    if let item = result as? NSMetadataItem {
        if let filePath = item.value(forAttribute: kMDItemPath as String) as? String {
            let fileURL = URL(fileURLWithPath: filePath)
            matchingFileURLs.append(fileURL)
        }
    }
}

if matchingFileURLs.count == 0 {
    print("No results")
} else if options.list {
    matchingFileURLs.forEach { (url) in
        print(url.path)
    }
} else {
    NSWorkspace.shared.activateFileViewerSelecting(matchingFileURLs)
}
