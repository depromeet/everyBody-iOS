//
//  MultiMoyaProvider.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/27.
//

import Foundation
import Moya

final class MultiMoyaProvider: MoyaProvider<MultiTarget> {
    
    var request: Cancellable?
    
    func requestDecoded<T: BaseTargetType>(_ target: T,
                                           completion: @escaping (Result<T.ResultModel?, Error>) -> Void) {
        addObserver()
        request(MultiTarget(target)) { result in
            switch result {
            case .success(let response):
                do {
                    let body = try JSONDecoder().decode(T.ResultModel.self, from: response.data)
                    completion(.success(body))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestNoResultAPI<T: BaseTargetType>(_ target: T,
                                               completion: @escaping (Result<Int?, Error>) -> Void) {
        addObserver()
        request = request(MultiTarget(target)) { result in
            switch result {
            case .success(let response):
                completion(.success(response.statusCode))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestWithProgress<T: BaseTargetType>(_ target: T,
                                                progressCompletion: @escaping ((ProgressResponse) -> Void),
                                                completion: @escaping (Result<Int?, Error>) -> Void) {
        addObserver()
        request = request(MultiTarget(target)) { progress in
            progressCompletion(progress)
        } completion: { result in
            switch result {
            case .success(let response):
                completion(.success(response.statusCode))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func requestDecodedMultiRepsonse<T: BaseTargetType, R: Decodable>(_ target: T,
                                                                      _ requestModel: R.Type,
                                                                      completion: @escaping (Result<R?, Error>) -> Void) {
        addObserver()
        request = request(MultiTarget(target)) { result in
            switch result {
            case .success(let response):
                do {
                    let body = try JSONDecoder().decode(R.self, from: response.data)
                    completion(.success(body))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(cancelRequest),
                                               name: Notification.Name("requestCancel"),
                                               object: nil)
    }
    
    @objc func cancelRequest(notification: NSNotification) {
        guard let request = request else {
            return
        }
        request.cancel()
    }
    
}
