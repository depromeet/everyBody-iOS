//
//  VideoAPI.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/16.
//

import Foundation

import Moya

enum VideoAPI: BaseTargetType {
    typealias ResultModel = Int
    
    case postImageKeyList(imageKeys: VideoRequestModel)
}

extension VideoAPI {
    
    var path: String {
        switch self {
        case .postImageKeyList:
            return HTTPMethodURL.POST.video
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postImageKeyList:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .postImageKeyList(let imageInfo):
            return .downloadParameters(parameters: ["keys": imageInfo.keys,
                                                    "duration": 0.5],
                                       encoding: JSONEncoding.default,
                                       destination: defaultDownloadDestination)
        }
    }
}

var videfileURL: URL?

private let defaultDownloadDestination: DownloadDestination = { _, response in
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename!)
    videfileURL = fileURL
    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
}
