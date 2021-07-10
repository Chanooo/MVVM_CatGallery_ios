//
//  UIImageVIew+.swift
//  Gallery
//
//  Created by CNOO on 2021/07/10.
//

import Foundation
import UIKit

extension UIImageView {
    
    func setImage(from image: GalleryImage) {
        let link = image.link
        ImageLoader(url: link).load { result in
            switch result {
            case .success(let _image):
                ImageCachingManager.shared.cachingList[link] = _image
                let size = CGSize(width: Int(image.width)!, height: Int(image.height)!)
                if let resized = _image.resizedImage(targetSize: size) {
                    self.image = resized
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}


