//
//  HostServerIPVO.swift
//  CrystalBallApp
//
//  Created by Kalyani on 27/02/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import Foundation
class HostServerIPVO {
    let ipAddress: String
    let port: String
    
    init(fn: String, ln: String) {
        self.ipAddress = fn
        self.port = ln
    }
}
