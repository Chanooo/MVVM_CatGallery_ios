//
//  GalleryData.swift
//  Gallery
//

import Foundation
import UIKit

// ----- 코드 수정 제한 영역 시작 -----

struct GalleryData: Codable {
    let statusCode: Int
    let body: Body

    struct Body: Codable {
        let images: [GalleryImage]?
        let nextPage: Bool?
        let error: String?

        enum CodingKeys: String, CodingKey {
            case images
            case nextPage = "next_page"
            case error
        }
    }
}

struct GalleryImage: Codable {
    let title: String
    let link: String
    let height: String
    let width: String
    var image: UIImage?

    enum CodingKeys: String, CodingKey {
        case title
        case link
        case height = "sizeheight"
        case width = "sizewidth"
    }
}

// ----- 코드 수정 제한 영역 끝 -----
