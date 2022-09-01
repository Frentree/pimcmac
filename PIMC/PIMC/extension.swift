//
//  extension.swift
//  PIMC
//
//  Created by gontai Kim on 2022/09/01.
//

import Cocoa

var isDarkMode: Bool {
    let mode = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
    return mode == "Dark"
}

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
