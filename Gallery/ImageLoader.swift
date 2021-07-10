//
//  ImageLoader.swift
//  Gallery
//

import UIKit

enum ImageLoaderError: Error {
    case unknown
    case invalidURL
}

/// 아래는 모두 자유롭게 수정할 수 있다.
/// 이미지 다운로드를 완료했을 때 적절한 위치에서 `DownloadImageDidFinish` Notification을 보내는 함수를 호출해야 한다.
struct ImageLoader {
    let url: String

    /// 함수의 parameter 또한 자유롭게 추가/수정 가능
    func load(completion: @escaping (Result<UIImage, ImageLoaderError>) -> Void) {
        if let url = URL(string: self.url) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard (response as? HTTPURLResponse)?.statusCode == 200,
                      error == nil,
                      let data = data,
                      let image = UIImage(data: data) else {
                    completion(.failure(.unknown))
                    return
                }

                completion(.success(image))

                // ----- 코드 수정 제한 영역 시작 -----
                NotificationCenter.default.post(name: .init("DownloadImageDidFinish"), object: nil)
                // ----- 코드 수정 제한 영역 끝 -----
            }.resume()
        } else {
            completion(.failure(.invalidURL))
        }
    }
}
