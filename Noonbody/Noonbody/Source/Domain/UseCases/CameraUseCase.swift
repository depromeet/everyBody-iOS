//
//  CameraUseCase.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/04.
//

import Foundation

import RxSwift

protocol CameraUseCase {
    func savePhoto(request: PhotoRequestModel)
}

final class DefaultCameraUseCase: CameraUseCase {

    private let cameraRepository: CameraRepository
    
    init(cameraRepository: CameraRepository) {
        self.cameraRepository = cameraRepository
    }

    func savePhoto(request: PhotoRequestModel) {
        return cameraRepository.postPhoto(request: request)
    }
    
}
