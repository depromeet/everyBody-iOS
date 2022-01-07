//
//  BaseTargetType.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/26.
//

import Moya
import Foundation

protocol BaseTargetType: Moya.TargetType {
    associatedtype ResultModel: Decodable
}

extension BaseTargetType {

    var baseURL: URL {
        // swiftlint:disable force_cast
        let url = Bundle.main.infoDictionary?["API_URL"] as! String
        return URL(string: "https://" + url)!
    }

    var headers: [String: String]? {
        // swiftlint:disable force_cast
        let token = UserManager.token ?? ""
        let header = [
            "Content-Type": "application/json",
            "Authorization": "Bearer " + token]
        return header
    }

    var sampleData: Data {
        return Data()
    }

}
