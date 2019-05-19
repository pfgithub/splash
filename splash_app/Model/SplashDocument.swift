//
//  SplashDocument.swift
//  splash
//
//  Created by Gonzo Fialho on 03/03/19.
//  Copyright © 2019 Gonzo Fialho. All rights reserved.
//

import UIKit

class SplashDocument: CodeDocument {
    
    override var documentationURL: URL? {
        return URL(string: "https://github.com/gonzula/splash/blob/master/Documentation/README.md");
    }

    override func compileAndRun(completion: @escaping (ExecutionError?) -> Void) {
        save(to: fileURL,
             for: .forOverwriting) { [unowned self] (completed) in
                guard completed else {
                    completion(.saveError)
                    return
                }

                let tempDirectoryPath = NSTemporaryDirectory()
                let shortcutPath = (tempDirectoryPath as NSString).appendingPathComponent("temp.shortcut")

                var errorMessage: UnsafeMutablePointer<Int8>?

                let parseError = parse(self.fileURL.path,
                                       shortcutPath,
                                       &errorMessage)
                if parseError != 0 {
                    print(errorMessage as Any)
                    let message = String(cString: errorMessage!)
                    completion(.compilationError(message))
                    free(errorMessage!)
                    return
                }

                completion(self.run(fromPath: shortcutPath))
        }
    }

    func run(fromPath path: String) -> ExecutionError? {
        let nsDictionary = NSDictionary(contentsOfFile: path)!
        // swiftlint:disable:next force_try
        let data = try! PropertyListSerialization.data(fromPropertyList: nsDictionary,
                                                       format: .binary,
                                                       options: 0)

        let b64 = "data:text/shortcut;base64," + data.base64EncodedString()
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
