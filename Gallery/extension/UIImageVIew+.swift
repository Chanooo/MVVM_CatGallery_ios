//
//  UIImageVIew+.swift
//  Gallery
//
//  Created by CNOO on 2021/07/10.
//

import Foundation
import UIKit

extension UIImageView {
    
    func setImage(from urlStr: String) {
        ImageLoader(url: urlStr).load { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    ImageCachingManager.shared.cachingList[urlStr] = image
                    self.image = image
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
}


