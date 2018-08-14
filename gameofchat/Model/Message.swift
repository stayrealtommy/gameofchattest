//
//  Message.swift
//  gameofchat
//
//  Created by Ma Wai Hung on 4/8/2018.
//  Copyright © 2018 EasyEngineering. All rights reserved.
//

import UIKit
import Firebase

@objcMembers class Message: NSObject {
    
    var fromId: String?
    var text: String?
    var timestamp: Int?
    var toId: String?
    
    var imageUrl: String?
    
    var imageHeight: Int?
    var imageWidth: Int?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId:fromId
    }
    
    init(from dictionary: [String: Any]) {
        super.init()
        imageUrl = dictionary["imageUrl"] as? String
        text = dictionary["text"] as? String
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        timestamp = dictionary["timestamp"] as? Int
        imageHeight = dictionary["imageHeight"] as? Int
        imageWidth = dictionary["imageWidth"] as? Int
        //videoUrl = dictionary["videoUrl"] as? String
    }

}
