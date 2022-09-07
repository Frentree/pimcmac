//
//  AboutViewController.swift
//  PIMC
//
//  Created by gontai Kim on 2022/09/05.
//

import Cocoa

class AboutViewController: NSViewController {
    
    @IBOutlet var appNameLabel: NSTextField!
    @IBOutlet var appVersionLabel: NSTextField!
    @IBOutlet var appIPLabel: NSTextField!
    @IBOutlet var appIconImageView: NSImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Read the app's info and reflect that content in the window's subviews:

        self.appIconImageView.image = #imageLiteral(resourceName: "ci")
        if let infoDictionary = Bundle.main.infoDictionary {
            self.appNameLabel.stringValue = infoDictionary["CFBundleName"] as? String ?? ""
            self.appVersionLabel.stringValue = infoDictionary["CFBundleShortVersionString"] as? String ?? ""
            let ip192 = getIFAddresses().filter { $0.contains(find:"192.") }.first
            self.appIPLabel.stringValue = ip192 ?? "Private IP Address not found."
//            self.appCopyrightLabel.stringValue = infoDictionary["NSHumanReadableCopyright"] as? String ?? ""

            // If you add more custom subviews to display additional information
            // about your app, configure them here
        }
    }
}

extension AboutViewController {
    // MARK: Storyboard instantiation
    static func freshController() ->AboutViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("AboutViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? AboutViewController else {
            fatalError("Why cant i find SampleViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
