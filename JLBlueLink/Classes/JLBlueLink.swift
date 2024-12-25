//
//  JLBlueLink.swift
//  Pods
//
//  Created by EzioChan on 2024/12/25.
//

import Foundation
import JL_BLEKit

public class JLBlueLink: NSObject {
    lazy var assistant = {
        JL_Assist()
    }
    public class func test() {
        print("JLBlueLink")
    }
}
