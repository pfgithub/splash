//
//  ScPLCompiler.swift
//  splash
//
//  Created by pfg on 5/3/19.
//  Copyright © 2019 Gonzo Fialho. All rights reserved.
//

import Foundation
import JavaScriptCore

/// An analyzer of sentiments
class ScPLCompiler: NSObject {
    /// Singleton instance. Much more resource-friendly than creating multiple new instances.
    static let shared = ScPLCompiler()
    private let jsvm = JSVirtualMachine()
    private let context: JSContext

    private override init() {
        let jsCode = try? String.init(contentsOf: Bundle.main.url(forResource: "parser.bundle", withExtension: "js")!)

        // Create a new JavaScript context that will contain the state of our evaluated JS code.
        self.context = JSContext(virtualMachine: self.jsvm)

        // Evaluate the JS code that defines the functions to be used later on.
        self.context.evaluateScript(jsCode)
    }

    /**
     Compile scpl code -> base64 data
     */
    func compile(_ scplCode: String, completion: @escaping (_ score: String) -> Void) {

        // Run this asynchronously in the background
        DispatchQueue.global(qos: .userInitiated).async {
            var base64 = "Error2"

            let parserModule = self.context.objectForKeyedSubscript("parser")
            if let result = parserModule?.objectForKeyedSubscript("parse")
                .call(withArguments: [
                    scplCode
                ]) {
                base64 = result.toString()
            }

            // Call the completion block on the main thread
            DispatchQueue.main.async {
                completion(base64)
            }
        }
    }

    // Inverse base64 data -> scpl code
    //  func inverse()
}
