//
//  SendFeedbackUseCase.swift
//  Noonbody
//
//  Created by kong on 2022/03/18.
//

import Foundation

import RxSwift

protocol SendFeedbackUseCase {
    func sendFeedback(request: FeedbackRequestModel) -> Observable<Int>
}

final class DefaultSendFeedbackUseCase: SendFeedbackUseCase {

    private let sendFeedbackRepository: DefaultSendFeedbackRepository
    
    init(sendFeedbackRepository: DefaultSendFeedbackRepository) {
        self.sendFeedbackRepository = sendFeedbackRepository
    }
    
    func sendFeedback(request: FeedbackRequestModel) -> Observable<Int> {
        return sendFeedbackRepository.sendFeedback(request: request)
    }
    
}
