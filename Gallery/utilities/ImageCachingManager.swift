//
//  ImageCachingManager.swift
//  Gallery
//
//  Created by CNOO on 2021/07/10.
//

import Foundation
import UIKit
class ImageCachingManager: NSObject {
    static let shared = ImageCachingManager()
    
    var cachingList: [String: UIImage] = [:]
}
