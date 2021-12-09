//
//  CameraRepository.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/04.
//

import Foundation

protocol CameraRepository {
    func postPhoto(request: PhotoRequestModel)
}

class DefaultCameraRepository: CameraRepository {
    
    func postPhoto(request: PhotoRequestModel) {
        CameraService.shared.postPhoto(request: request) { response in
            switch response {
            case .success:
                print("성공적으로 저장되었습니다.")
            case .failure:
                print("알 수 없는 에러가 발생했습니다.")
            }
        }
    }
    
}
