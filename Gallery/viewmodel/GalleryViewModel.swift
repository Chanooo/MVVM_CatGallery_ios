//
//  GalleryViewModel.swift
//  Gallery
//
//  Created by CNOO on 2021/07/10.
//

import Foundation


class GalleryViewModel: NSObject {
    
    static let LIMIT_COUNT = 50
    private var galleryData: [GalleryImage] = []
    
    var reloadClosure: ((GalleryError?, String?) -> Void)?
    var hasNextPage = true
    
    func fetchImages(start: Int) {
        
        if start >= 1000 {
            return
        }
        
        // GalleryRequest 사용 예시 (확인 후 제거 가능)
        DispatchQueue.global(qos: .background).async {
            GalleryRequest(display: GalleryViewModel.LIMIT_COUNT, start: start).send() { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        print(data)
                        
                        // 로드한 이미지 개수랑 맞추기 위해...
                        // 했는데  문제가 좀 있네요 ㅠㅠ
//                        self?.preloadImages(urls: data.images) {
//                        }
                        if let images = data.images {
                            self?.galleryData.append(contentsOf: images)
                        }
                        self?.hasNextPage = data.nextPage ?? true
                        self?.reloadClosure?(nil, data.error)
                        
                        
                    case .failure(let error):
                        self?.reloadClosure?(error, nil)
                    }
                }
            }
        }
    }
    
    /*
    func preloadImages(urls: [GalleryImage]?, completion: @escaping () -> () ) {
        var cnt = 0
        if let urls = urls {
            urls.forEach { img in
                let link = img.link
                if ImageCachingManager.shared.cachingList[link] == nil {
                    ImageLoader(url: link).load { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let image):
                                ImageCachingManager.shared.cachingList[link] = image
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                            
                            cnt += 1
                            if cnt == urls.count {
                                completion()
                            }
                        }
                    }
                }
            }
        } else {
            completion()
        }
        
    }
 */
    
    func refreshImages() {
        galleryData.removeAll()
        fetchImages(start: 1)
    }
    
    func getDataCount() -> Int {
        return galleryData.count
    }
    
    func getData(index: IndexPath) -> GalleryImage? {
        if galleryData.count-1 < index.row {
            return nil
        }
        return galleryData[index.row]
    }
    
}
