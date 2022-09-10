//
//  ViewController.swift
//  PIMC
//
//  Created by gontai Kim on 2022/08/26.
//

import Cocoa
import Security
import ServiceManagement

class ViewController: NSViewController {

    var logArchive: String = ""
    // NSXPC
    var connection: NSXPCConnection?
    var authRef: AuthorizationRef?

    //
    var mTimer : Timer?
    
    @IBOutlet weak var version: NSTextField!
    @IBOutlet var resultTextView: NSTextView!

    @IBAction func actionRunButton(_ sender: Any) {
        run()
    }

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

    func run() {
        printToResult(data: "Wait for result ...\n")
        
        // checking process
        if let timer = mTimer {
            if !timer.isValid {
                mTimer = Timer.scheduledTimer(timeInterval: Constants.TIME_INTERVAL, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
                mTimer?.fire()
            }
        }else{
            mTimer = Timer.scheduledTimer(timeInterval: Constants.TIME_INTERVAL, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            mTimer?.fire()
        }
        
    }
    
    @objc func timerCallback() {
        //
        let result = shell("ps -aef | grep er2 | grep -v grep")
        printToResult(data: result)
        
        //
        if result.contains("er2-agent") {

            let reply = shell("/usr/local/er2/er2-config -t")
            printToResult(data: reply)
            changeIconFromResult(result: reply)
            
        } else {
            // set default icon
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.statusBar?.changeIconDefault()
        }
    }

    func printToResult(data:String) {
//        print(data)
//        resultTextView.string = "\(data)"
    }

    func changeIconFromResult(result: String) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate

        // icon
        if result.containsIgnoringCase(find: "Test SUCCESS.") {
            if isDarkMode {
                appDelegate.statusBar?.changeIcon(image: #imageLiteral(resourceName: "logo white"))
            } else {
                appDelegate.statusBar?.changeIcon(image: #imageLiteral(resourceName: "logo black"))
            }
        } else {
            appDelegate.statusBar?.changeIconDefault()
        }
    }

    //
    func printLog(_ message:String) -> Void {
           print(message)
           if self.resultTextView != nil {
               DispatchQueue.main.async {
                   self.resultTextView.string += "\n" + message
               }
           } else {
               logArchive += "\n" + message
           }
       }

}

extension ViewController {
    // MARK: Storyboard instantiation
    static func freshController() ->ViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ViewController else {
            fatalError("Why cant i find SampleViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}

