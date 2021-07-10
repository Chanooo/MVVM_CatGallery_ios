//
//  GalleryRequest.swift
//  Gallery
//

import Foundation

// ----- 코드 수정 제한 영역 시작 -----

enum GalleryError: Int, Error {
    case unknown = -1
    case jsonError = -2
    case invalidArgument = -3
    case badRequest = 400
    case notFound = 404
    case internalServerError = 500
}

/// 갤러리 데이터를 불러오는 기능을 담당
struct GalleryRequest {

    /// 갤러리에 담을 이미지 불러오는 API의 URL
    static let url: String = "https://rabh97p6f8.execute-api.us-east-2.amazonaws.com/challenge/images"

    /// 검색 결과 출력 건수 지정 (10 부터 최대 100 까지 가능)
    let display: Int

    /// 검색 시작 위치 지정 (1 부터 최대 1000 까지 가능)
    let start: Int

    /// GalleryRequest의 생성자
    ///
    /// - parameter display: 검색 결과 출력 건수 지정 (10 부터 최대 100 까지 가능)
    /// - parameter start: 검색 시작 위치 지정 (1 부터 최대 1000 까지 가능)
    init(display: Int, start: Int) {
        self.display = display
        self.start = start
    }

    /// 갤러리에 담을 이미지를 검색하여 불러오는 API를 호출하는 함수
    ///
    /// - parameter error: 테스트용 에러 요청시 사용하고 미입력시 정상 응답 반환 (400, 404, 500 에러만 가능)
    /// - parameter completion: API 응답을 Result 타입으로 반환
    func send(error: GalleryError? = nil, completion: @escaping (Result<GalleryData.Body, GalleryError>) -> Void) {
        var components = URLComponents(string: GalleryRequest.url)
        var items: [URLQueryItem] = [
            URLQueryItem(name: "display", value: "\(display)"),
            URLQueryItem(name: "start", value: "\(start)")
//            URLQueryItem(name: "err", value: "500")
        ]

        if !((10...100) ~= display && (1...1000) ~= start) {
            completion(.failure(.invalidArgument))
            return
        }

        if let error = error {
            if [.badRequest, .notFound, .internalServerError].contains(error) {
                items.append(URLQueryItem(name: "err", value: "\(error.rawValue)"))
            } else {
                completion(.failure(.invalidArgument))
                return
            }
        }

        components?.queryItems = items

        if let url = components?.url {
            URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                if let data = data {
                    do {
                        let json: GalleryData = try JSONDecoder().decode(GalleryData.self, from: data)
                        if json.statusCode == 200 {
                            completion(.success(json.body))
                        } else {
                            let galleryError = GalleryError(rawValue: json.statusCode) ?? .unknown
                            completion(.failure(galleryError))
                        }
                    } catch {
                        completion(.failure(.jsonError))
                    }
                } else {
                    completion(.failure(.unknown))
                }
            }).resume()
        }
    }
}

// ----- 코드 수정 제한 영역 끝 -----
