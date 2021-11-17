//
//  AlbumViewModel.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/11.
//

import Foundation

import RxSwift

struct AlbumViewModel {
    
    var dummy: [Album] = [Album(id: 0, name: "유경이의 눈바디", thumbnailURL: "", createdAt: "", albumDescription: "6일간의 기록",
                                pictures: Pictures(lower: [], upper: [], whole: [])),
                          Album(id: 0, name: "유경이의 눈바디", thumbnailURL: "", createdAt: "", albumDescription: "6일간의 기록",
                                                      pictures: Pictures(lower: [], upper: [], whole: [])),
                          Album(id: 0, name: "유경이의 눈바디", thumbnailURL: "", createdAt: "", albumDescription: "6일간의 기록",
                                                      pictures: Pictures(lower: [], upper: [], whole: []))]
    lazy var albumDummy = BehaviorSubject<[Album]>(value: dummy)
}
