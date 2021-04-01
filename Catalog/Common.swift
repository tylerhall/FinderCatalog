//
//  Shared.swift
//  Catalog
//
//  Created by Tyler Hall on 10/31/21.
//

import Cocoa
import CoreSpotlight

class Common {

    static let shared = Common()

    var query: NSMetadataQuery?
    var gotResults: (([URL]) -> ())?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(queryFoundResults), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
    }

    func findCatalogFiles(catalogIndex: String, fullText: Bool) {
        query = NSMetadataQuery()
        query?.operationQueue = OperationQueue()

        let strMatch = "*" + catalogIndex + "*"

        if fullText {
            query?.predicate = NSPredicate(format: "(kMDItemFSName like[c] %@) OR (kMDItemTextContent like[c] %@)", argumentArray: [strMatch, strMatch])
        } else {
            query?.predicate = NSPredicate(format: "kMDItemFSName like[c] %@", argumentArray: [strMatch])
        }

        query?.operationQueue?.addOperation { [weak self] in
            self?.query?.start()
        }
    }

    @objc func queryFoundResults() {
        query?.stop()

        guard let query = query else { gotResults?([]); return }

        var matchingFileURLs = [URL]()
        for result in query.results {
            if let item = result as? NSMetadataItem {
                if let filePath = item.value(forAttribute: kMDItemPath as String) as? String {
                    let fileURL = URL(fileURLWithPath: filePath)
                    matchingFileURLs.append(fileURL)
                }
            }
        }

        gotResults?(matchingFileURLs)
    }
}

extension String {
    func nsRange(from range: Range<Index>) -> NSRange {
        guard let lower = UTF16View.Index(range.lowerBound, within: utf16) else { return .init() }
        guard let upper = UTF16View.Index(range.upperBound, within: utf16) else { return .init() }
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: lower), length: utf16.distance(from: lower, to: upper))
    }
}
