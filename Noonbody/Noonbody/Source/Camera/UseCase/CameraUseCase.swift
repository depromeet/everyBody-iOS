//
//  CameraUseCase.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/04.
//

import Foundation

import RxSwift

protocol CameraUseCase {
    func postPhoto(request: PhotoRequestModel)
}

final class DefaultCameraUseCase: CameraUseCase {

    private let cameraRepository: CameraRepository
    
    init(cameraRepository: CameraRepository) {
        self.cameraRepository = cameraRepository
    }

    func postPhoto(request: PhotoRequestModel) {
        return cameraRepository.postPhoto(request: request)
    }
    

}
