//
//  AppAuthorizationRights.swift
//  PIMC
//
//  Created by gontai Kim on 2022/08/29.
//

import Foundation

struct AppAuthorizationRights {

    // Define all authorization right definitions this application will use (only one for this app)
    static let shellRightName: NSString = "com.frentree.recon.PIMC.runCommand"
    static let shellRightDefaultRule: Dictionary = shellAdminRightsRule
    static let shellRightDescription: CFString = "PrivilegedTaskRunner wants to run the command ''" as CFString

    // Set up authorization rules (only one for this app)
    static var shellAdminRightsRule: [String:Any] = ["class" : "user",
                                                     "group" : "admin",
                                                     "timeout" : 0,
                                                     "version" : 1]
}
