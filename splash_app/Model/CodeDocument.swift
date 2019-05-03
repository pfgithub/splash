//
//  CodeDocument.swift
//  splash
//
//  Created by pfg on 5/3/19.
//  Copyright © 2019 Gonzo Fialho. All rights reserved.
//

import UIKit

class CodeDocument: UIDocument {
    enum ExecutionError: LocalizedError, Equatable {
        case saveError
        case compilationError(String)
        case shortcutsNotFound
        
        var errorDescription: String? {
            switch self {
            case .saveError: return "Unknown error when saving file"
            case .compilationError(let message): return "Compilation error: \(message)"
            case .shortcutsNotFound: return "Shortctus app not found."
            }
        }
    }
    
    /// Just the last path component with extension
    var fileName: String {
        return (self.fileURL.path as NSString)
            .lastPathComponent
    }
    
    /// File name without extension
    var fileTitle: String {
        return (fileName as NSString)
            .deletingPathExtension
    }
    
    var string = String() {
        didSet {
            string.formatForCode()
        }
    }
    
    override func contents(forType typeName: String) throws -> Any {
        string.formatForCode()
        let data = string.data(using: .utf8)!
        return data
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else {return}
        self.string = String(data: data, encoding: .utf8)!
    }
    
    func compileAndRun(completion: @escaping (ExecutionError?) -> Void) {
        save(to: fileURL,
             for: .forOverwriting) { (completed) in
                completion(.compilationError("This document is neither SPLASH nor ScPL and cannot be run."))
        }
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
