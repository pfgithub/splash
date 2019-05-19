//
//  ScPLDocument.swift
//  splash
//
//  Created by pfg on 5/3/19.
//  Copyright © 2019 Gonzo Fialho. All rights reserved.
//

import UIKit

class ScPLDocument: CodeDocument {
    
    override var documentationURL: URL? {
        return URL(string: "https://docs.scpl.dev/");
    }
    
    override func compileAndRun(completion: @escaping (ExecutionError?) -> Void) {
        save(to: fileURL,
             for: .forOverwriting) { [unowned self] (completed) in
                guard completed else {
                    completion(.saveError)
                    return
                }

                ScPLCompiler.shared.compile(self.string, completion: { base64 in
                    completion(self.run(base64: base64))
                })
        }
    }

    func run(base64: String) -> ExecutionError? {
        let b64 = "data:text/shortcut;base64," + base64
        var urlComponents = URLComponents(string: "shortcuts://import-shortcut")!
        let queryItems = [URLQueryItem(name: "name", value: fileTitle),
                          URLQueryItem(name: "url", value: b64)]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url,
                                      options: [:],
                                      completionHandler: nil)
        } else {
            return .shortcutsNotFound
        }
        return nil
    }
}

private extension String {
    mutating func formatForCode() {
        convertToLF()
        appendTrailingNewLineIfNeeded()
    }

    private mutating func convertToLF() {
        self = replacingOccurrences(of: "\r\n", with: "\n")
        self = replacingOccurrences(of: "\r", with: "")
    }

    private mutating func appendTrailingNewLineIfNeeded() {
        if !hasSuffix("\n") {
            append("\n")
        }
    }
}
