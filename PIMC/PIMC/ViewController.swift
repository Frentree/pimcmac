//
//  ViewController.swift
//  PIMC
//
//  Created by gontai Kim on 2022/08/26.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var version: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 버전 출력
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        version.stringValue = "Version : \(appVersion)"
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

