//
//  AlbumAPI.swift
//  everyBody-iOS
//
//  Created by kong on 2021/12/03.
//

import Foundation

import Moya

enum AlbumAPI: BaseTargetType {
    typealias ResultModel = [Album]
    
    case getAlbumList
    case savePhoto(request: PictureRequestModel)
    case sendFeedback(request: FeedbackRequestModel)
}

extension AlbumAPI {
    
    var path: String {
        switch self {
        case .getAlbumList:
            return HTTPMethodURL.GET.album
        case .savePhoto:
            return HTTPMethodURL.POST.photo
        case .sendFeedback:
            return HTTPMethodURL.POST.feedback
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAlbumList:
            return .get
        case .savePhoto:
            return .post
        case .sendFeedback:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getAlbumList:
            return .requestPlain
        case .savePhoto(let request):
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
        case .sendFeedback(let request):
            return .requestParameters(parameters: ["content" : request.content,
                                                   "star_rate": request.starRate],
                                      encoding: JSONEncoding.default)
        }
    }
}
