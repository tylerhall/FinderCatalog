//
//  AppDelegate.swift
//  Catalog
//
//  Created by Tyler Hall on 10/30/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleURLEvent(_:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        Common.shared.query?.stop()

        Common.shared.gotResults = { matchingFileURLs in
            if matchingFileURLs.count == 0 {
                NSSound.beep()
            }
            NSWorkspace.shared.activateFileViewerSelecting(matchingFileURLs)
        }

        guard let urlStr = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue else { return }
        guard var catalogIndex = URL(string: urlStr)?.host else { return }

        let range = catalogIndex.nsRange(from: catalogIndex.startIndex..<catalogIndex.endIndex)
        let regex1 = try! NSRegularExpression(pattern: "^[a-zA-Z]{3}[0-9]+$", options: .init())
        let regex2 = try! NSRegularExpression(pattern: "^[a-zA-Z]{3}[0-9]+[zZ]$", options: .init())

        if regex1.numberOfMatches(in: catalogIndex, options: .init(), range: range) == 1 {
            Common.shared.findCatalogFiles(catalogIndex: catalogIndex, fullText: false)
        } else if regex2.numberOfMatches(in: catalogIndex, options: .init(), range: range) == 1 {
            catalogIndex = String(catalogIndex.dropLast())
            Common.shared.findCatalogFiles(catalogIndex: catalogIndex, fullText: true)
        } else {
            NSSound.beep()
        }
    }
}
