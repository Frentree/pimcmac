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
        callHelperWithAuthorization()
    }

    func printToResult(data:String) {
        resultTextView.string = "\(data)"
    }

    //
    func printLog(_ message:String) -> Void {
           print(message)
           if self.resultTextView != nil {
               DispatchQueue.main.async {
                   self.resultTextView.string += "\n" + message
               }
           }else {
               logArchive += "\n" + message
           }
       }

    /// Initialize AuthorizationRef, as we need to manage it's lifecycle
    func initAuthorizationRef() {
        // Create an empty AuthorizationRef
        let status = AuthorizationCreate(nil, nil, AuthorizationFlags(), &authRef)
        if (status != OSStatus(errAuthorizationSuccess)) {
            printLog("AppviewController: AuthorizationCreate failed")
            return
        }
    }

    /// Free AuthorizationRef, as we need to manage it's lifecycle
    func freeAuthorizationRef() {
        AuthorizationFree(authRef!, AuthorizationFlags.destroyRights)
    }

    /// Check if Helper daemon exists
    func checkIfHelperDaemonExists() -> Bool {

        var foundAlreadyInstalledDaemon = false

        // Daemon path, if it is already installed
        let helperURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LaunchServices/\(HelperConstants.machServiceName)")
        let helperBundleInfo = CFBundleCopyInfoDictionaryForURL(helperURL as CFURL?)
        if helperBundleInfo != nil {
            foundAlreadyInstalledDaemon = true
        }

        return foundAlreadyInstalledDaemon
    }

    func installHelperDaemon() {
        // Create authorization reference for the user
        var authRef: AuthorizationRef?
        var authStatus = AuthorizationCreate(nil, nil, [], &authRef)

        // Check if the reference is valid
        guard authStatus == errAuthorizationSuccess else {
            printLog("AppviewController: Authorization failed: \(authStatus)")
            return
        }

        // Ask user for the admin privileges to install the
        var authItem = AuthorizationItem(name: kSMRightBlessPrivilegedHelper, valueLength: 0, value: nil, flags: 0)
        var authRights = AuthorizationRights(count: 1, items: &authItem)
        let flags: AuthorizationFlags = [[], .interactionAllowed, .extendRights, .preAuthorize]
        authStatus = AuthorizationCreate(&authRights, nil, flags, &authRef)

        // Check if the authorization went succesfully
        guard authStatus == errAuthorizationSuccess else {
            printLog("AppviewController: Couldn't obtain admin privileges: \(authStatus)")
            return
        }

        // Launch the privileged helper using SMJobBless tool
        var error: Unmanaged<CFError>? = nil

        if(SMJobBless(kSMDomainSystemLaunchd, HelperConstants.machServiceName as CFString, authRef, &error) == false) {
            let blessError = error!.takeRetainedValue() as Error
            printLog("AppviewController: Bless Error: \(blessError)")
        } else {
            printLog("AppviewController: \(HelperConstants.machServiceName) installed successfully")
        }

        // Release the Authorization Reference
        AuthorizationFree(authRef!, [])
    }

    /// Prepare XPC connection for inter process call
    ///
    /// - returns: A reference to the prepared instance variable
    func prepareXPC() -> NSXPCConnection? {

        // Check that the connection is valid before trying to do an inter process call to helper
        if(connection==nil) {
            connection = NSXPCConnection(machServiceName: HelperConstants.machServiceName, options: NSXPCConnection.Options.privileged)
            connection?.remoteObjectInterface = NSXPCInterface(with: RemoteProcessProtocol.self)
            connection?.invalidationHandler = {
                self.connection?.invalidationHandler = nil
                OperationQueue.main.addOperation() {
                    self.connection = nil
                    self.printLog("AppviewController: XPC Connection Invalidated")
                }
            }
            connection?.resume()
        }

        return connection
    }

    /// Compare app's helper version to installed daemon's version and update if necessary
    func checkHelperVersionAndUpdateIfNecessary(callback: @escaping (Bool) -> Void) {
        // Daemon path
        let helperURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LaunchServices/\(HelperConstants.machServiceName)")
        let helperBundleInfo = CFBundleCopyInfoDictionaryForURL(helperURL as CFURL)
        if helperBundleInfo != nil {
            let helperInfo = helperBundleInfo! as NSDictionary
            let helperVersion = helperInfo["CFBundleVersion"] as! String

            printLog("AppviewController: PrivilegedTaskRunner Bundle Version => \(helperVersion)")

            // When the connection is valid, do the actual inter process call
            let xpcService = prepareXPC()?.remoteObjectProxyWithErrorHandler() { error -> Void in
                callback(false)
            } as? RemoteProcessProtocol

            xpcService?.getVersion(reply: {
                installedVersion in
                self.printLog("AppviewController: PrivilegedTaskRunner Helper Installed Version => \(installedVersion)")
                callback(installedVersion == helperVersion)
            })
        }else {
            callback(false)
        }
    }

    /// Call Helper using XPC with authorization
    func callHelperWithAuthorization() {
        var authRefExtForm = AuthorizationExternalForm()
        let timeout:Int = 5

        // Make an external form of the AuthorizationRef
        var status = AuthorizationMakeExternalForm(authRef!, &authRefExtForm)
        if (status != OSStatus(errAuthorizationSuccess)) {
            printLog("AppviewController: AuthorizationMakeExternalForm failed")
            return
        }

        // Add all or update required authorization right definition to the authorization database
        var currentRight:CFDictionary?

        // Try to get the authorization right definition from the database
        print(AppAuthorizationRights.shellRightName.utf8String);
        status = AuthorizationRightGet(AppAuthorizationRights.shellRightName.utf8String!, &currentRight)

        if (status == errAuthorizationDenied) {
            print("errAuthorizationDenied")
            var defaultRules = AppAuthorizationRights.shellRightDefaultRule
            defaultRules.updateValue(timeout as AnyObject, forKey: "timeout")
            status = AuthorizationRightSet(authRef!, AppAuthorizationRights.shellRightName.utf8String!, defaultRules as CFDictionary, AppAuthorizationRights.shellRightDescription, nil, "Common" as CFString)
            printLog("AppviewController: : Adding authorization right to the security database")
        }

        // We need to put the AuthorizationRef to a form that can be passed through inter process call
        let authData = NSData.init(bytes: &authRefExtForm, length:Int(kAuthorizationExternalFormLength))

        // When the connection is valid, do the actual inter process call
        let xpcService = prepareXPC()?.remoteObjectProxyWithErrorHandler() { error -> Void in
            self.printLog("AppviewController: XPC error: \(error)")
        } as? RemoteProcessProtocol
        xpcService?.runCommand(path: "/usr/local/er2/er2-config", authData: authData, reply: {
            reply in
            // Let's update GUI asynchronously
            DispatchQueue.global(qos: .background).async {
                // Background Thread
                DispatchQueue.main.async {
                    // Run UI Updates
                    print("\n=== result ===\n\(reply)\n=== end ===\n")
                    self.printToResult(data: reply)
                }
            }
        })
    }

    func clearSecurity() {
        // Remove this app's specific authorization information from the security database
        let status = AuthorizationRightRemove(authRef!, AppAuthorizationRights.shellRightName.utf8String!)

        if(status == errAuthorizationSuccess) {
            print("AppviewController: AuthorizationRightRemove was successful")
        }else {
            print("AppviewController: AuthorizationRightRemove failed")
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

