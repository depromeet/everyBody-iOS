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
    case deletePicture(pictureId: Int)
    case savePhoto(request: PhotoRequestModel)
}

extension AlbumAPI {
    
    var path: String {
        switch self {
        case .getAlbumList:
            return HTTPMethodURL.GET.album
        case .deletePicture(let pictureId):
            return HTTPMethodURL.DELETE.pictures + "/\(pictureId)"
        case .savePhoto:
            return HTTPMethodURL.POST.photo
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAlbumList:
            return .get
        case .deletePicture:
            return .delete
        case .savePhoto:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getAlbumList:
            return .requestPlain
        case .deletePicture:
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
        }
    }
}
