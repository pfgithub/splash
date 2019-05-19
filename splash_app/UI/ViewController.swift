//
//  ViewController.swift
//  splash
//
//  Created by Gonzo Fialho on 02/03/19.
//  Copyright © 2019 Gonzo Fialho. All rights reserved.
//

import UIKit

class ViewController: UIDocumentBrowserViewController {

    let browserDelegate = BrowserDelegate()  // swiftlint:disable:this weak_delegate
    var transitioningController: UIDocumentBrowserTransitionController?

    var observers = [Any]()

    init() {
        super.init(forOpeningFilesWithContentTypes: ["ninja.gonzo.splash.script", "dev.scpl.scpl.script"])
        delegate = browserDelegate
        let button = UIBarButtonItem(title: "Settings",
                                     style: .plain,
                                     target: self,
                                     action: #selector(presentSettings(sender:)))
        additionalLeadingNavigationBarButtonItems.append(button)
    }

    required init?(coder aDecoder: NSCoder) {fatalError("init(coder:) has not been implemented")}

    override func viewDidLoad() {
        super.viewDidLoad()

        observers.append( // swiftlint:disable:next discarded_notification_center_observer
            NotificationCenter.default.addObserver(forName: .themeChanged,
                                                   object: nil,
                                                   queue: nil,
                                                   using: { [weak self] _ in
                                                    self?.setupAppearance()
            })
        )
        setupAppearance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if UserDefaults.standard.alreadyShowedOnboard1 == false {
            present(OnboardViewController(), animated: animated)
            perform(#selector(showExamplesDelayed), with: nil, afterDelay: 0.5)
        }
    }

    func setupAppearance() {
        let theme = ThemeManager.shared.theme

        browserUserInterfaceStyle = theme.browserUserInterfaceStyle
    }

    func presentEditor(withURL url: URL) {
        if let presentedViewController = presentedViewController {
            if let editor = presentedViewController as? EditorNavigationController {
                editor.close {
                    self.presentEditor(withURL: url)
                }
            } else {
                presentedViewController.dismiss(animated: true) {
                    self.presentEditor(withURL: url)
                }
            }
            return
        }

        let editorViewController = EditorNavigationController()
        // if fileurl endswith .splash
        var document: CodeDocument

        switch url.pathExtension {
        case "splash":
            document = SplashDocument(fileURL: url)
        case "scpl":
            document = ScPLDocument(fileURL: url)
        default:
            document = CodeDocument(fileURL: url)
        }

        editorViewController.transitioningDelegate = self
        let transitioningController = transitionController(forDocumentAt: url)
        transitioningController.targetView = editorViewController.view

        self.transitioningController = transitioningController

        editorViewController.set(document) {
            self.present(editorViewController, animated: true, completion: nil)
        }

        print(Thread.isMainThread)
    }

    @objc
    func showExamplesDelayed() {
        showExamplesInRecents()
    }

    func showExamplesInRecents(_ fileNames: [String]? = nil, completion: (() -> Void)? = nil) {
        let fileNames = fileNames ?? ["Age", "Leap Year", "Quadratic Solver"].map {$0 + ".splash"}
        guard let fileName = fileNames.first else {
            completion?()
            return
        }
        let remainingFiles = Array(fileNames.dropFirst())
        let documentsPath = FileManager.documentsDirectory.path
        let examplesPath = (documentsPath as NSString).appendingPathComponent("Examples")
        let fullFileName = (examplesPath as NSString).appendingPathComponent(fileName)
        let url = URL(fileURLWithPath: fullFileName)

        let data = Bundle.main.dataFromResource(fileName: fileName)
        try! data.write(to: URL(fileURLWithPath: fullFileName))  // swiftlint:disable:this force_try

        revealDocument(at: url,
                       importIfNeeded: false) { (_, _) in
                        DispatchQueue.main.async {
                            self.showExamplesInRecents(remainingFiles, completion: completion)
                        }
        }
    }

    // MARK: - User Interaction

    @objc func presentSettings(sender: UIBarButtonItem?) {
        let viewController = SettingsNavigationController()
        if UIDevice.current.userInterfaceIdiom == .pad {
            viewController.modalPresentationStyle = .popover
            viewController.popoverPresentationController?.barButtonItem = sender
            viewController.popoverPresentationController?.permittedArrowDirections = .any
            viewController.popoverPresentationController?.canOverlapSourceViewRect = false
            self.present(viewController, animated: true, completion: nil)
        } else {
            self.present(viewController, animated: true, completion: nil)
        }
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitioningController!
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitioningController!
    }
}
