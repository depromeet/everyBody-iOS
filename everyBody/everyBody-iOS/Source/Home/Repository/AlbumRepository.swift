//
//  AlbumRepository.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/02.
//

import Foundation

protocol AlbumRepository {
    func postCreateAlbum(request: CreateAlbumRequestModel)
}

class DefaultAlbumRepositry: AlbumRepository {
    
    func postCreateAlbum(request: CreateAlbumRequestModel) {
        CreateAlbumService.shared.postCreateAlbum(request: request) { response in
            switch response {
            case .success:
                print("성공적으로 생성되었습니다.")
            case .failure:
                print("알 수 없는 에러가 발생했습니다.")
            }
        }
    }
    
}
