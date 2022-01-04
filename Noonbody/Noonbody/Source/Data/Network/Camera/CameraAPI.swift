//
//  CameraAPI.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/04.
//

import Foundation

import Moya

enum CameraAPI: BaseTargetType {
    typealias ResultModel = NotificationConfig
    
    case postPhoto(request: PhotoRequestModel)
}

extension CameraAPI {
    
    var path: String {
        switch self {
        case .postPhoto:
            return HTTPMethodURL.POST.photo
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postPhoto:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .postPhoto(let request):
            var multiPartFormData: [MultipartFormData] = []
            
            let parameters: [String: Any] = [
                "album_id": request.albumId,
                "body_part": request.bodyPart,
                "taken_at": request.takenAt
            ]
            for (key, value) in parameters {
                multiPartFormData.append(MultipartFormData(provider: .data("\(value)".data(using: .utf8)!),
                                                           name: key))
            }
            
            let imageData = request.image.jpegData(compressionQuality: 1.0)
            let multipartImage = MultipartFormData(provider: .data(imageData!),
                                                   name: "image",
                                                   fileName: "image",
                                                   mimeType: "image/jpeg")
            
            multiPartFormData.append(multipartImage)
            
            return .uploadMultipart(multiPartFormData)
        }
    }
    
}
