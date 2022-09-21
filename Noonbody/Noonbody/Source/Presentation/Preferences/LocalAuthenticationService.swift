//
//  LocalAuthenticationService.swift
//  Noonbody
//
//  Created by kong on 2022/08/17.
//

import Foundation

import LocalAuthentication

public class LocalAuthenticationService {
    static let shared = LocalAuthenticationService()
    
    func evaluateAuthentication(completion: @escaping (Bool, Error?) -> Void) {
        let autoContext = LAContext()
        var error: NSError?
        if autoContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            // Face ID가 등록된 경우는 Face ID로, Touch ID가 등록된 경우는 Touch ID로 인증 실행
            // 등록되어 있지 않다면 비밀번호
            autoContext.evaluatePolicy(.deviceOwnerAuthentication,
                                   localizedReason: "인증이 필요합니다.") { [weak self] (response, error) in
                if let error = error { self!.onError(error: error as NSError) }
                completion(response, error)
            }
        } else {
            // 생체인증 사용 불가능한 디바이스이거나 생체인증이 등록되어있지 않음
            print("Local Authentication is not available")
        }
    }
    
    func onError(error: NSError) {
        switch error.code {
        case LAError.authenticationFailed.rawValue:
            print("authenticationFailed")
        case LAError.biometryNotEnrolled.rawValue:
            print("biometryNotEnrolled")
        case LAError.userFallback.rawValue:
            print("userFallback")
        default:
            break
        }
    }
    
}
