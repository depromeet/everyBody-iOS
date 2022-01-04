//
//  NotificationViewModel.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/03.
//

import Foundation

import RxCocoa
import RxSwift

struct NotificationViewModel {
    
    public let weekday = ["일", "월", "화", "수", "목", "금", "토"]
    
    private let profileUseCase: DefaultProfileUseCase
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let dayList: Observable<[State]>
        let time: Observable<String>
//        let isActived: Observable<Bool>
        let saveButtonControlEvent: ControlEvent<Void>
    }
    
    struct Output {
        let dayConfig: Driver<[Bool]>
        let timeConfig: Driver<[Int]>
        let statusCode: Driver<Int>
    }
    
    init(profileUseCase: DefaultProfileUseCase) {
        self.profileUseCase = profileUseCase
    }
    
    func transform(input: Input) -> Output {
        let userConfigInfo = Observable.combineLatest(input.dayList, input.time)
        
        let response = input.viewWillAppear
            .flatMap { self.profileUseCase.getNotificationConfig() }
            .map { $0 }
            .share()
        
        let dayConfig = response
            .compactMap { $0 }
            .map { response -> [Bool] in
                return [response.sunday,
                        response.monday,
                        response.tuesday,
                        response.wednesday,
                        response.thursday,
                        response.friday,
                        response.saturday]
            }.asDriver(onErrorJustReturn: [])
        
        let timeConfig = response
            .compactMap { $0 }
            .map { response -> [Int] in
                return [response.preferredTimeHour,
                        response.preferredTimeMinute]
            }.asDriver(onErrorJustReturn: [])
        
        let putResponse = input.saveButtonControlEvent.withLatestFrom(userConfigInfo)
            .map { dayList, time -> NotificationConfig in
                let time = time.split(separator: ":").map { Int(String($0))! }
                let hour = time[0]
                let minute = time[1]
                let dayList = dayList.map { $0 == .selected ? true : false }
                return NotificationConfig(monday: dayList[1],
                                          tuesday: dayList[2],
                                          wednesday: dayList[3],
                                          thursday: dayList[4],
                                          friday: dayList[5],
                                          saturday: dayList[6],
                                          sunday: dayList[0],
                                          preferredTimeHour: hour,
                                          preferredTimeMinute: minute,
                                          isActivated: true)
            }
            .flatMap { request in
                self.profileUseCase.putNotificationConfig(request: request)
            }
            .share()
        
        let statusCode = putResponse
                        .compactMap { $0 }
                        .map { response -> Int in
                            return response
                        }.asDriver(onErrorJustReturn: 404)
        
        return Output(dayConfig: dayConfig, timeConfig: timeConfig, statusCode: statusCode)
    }
    
}
