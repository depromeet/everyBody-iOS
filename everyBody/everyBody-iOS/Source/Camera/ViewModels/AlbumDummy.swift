//
//  AlbumDummy.swift
//  everyBody-iOS
//
//  Created by kong on 2021/12/03.
//

import Foundation

import RxSwift
import RxCocoa

struct AlbumDaummy {
    var dummy: [Album] = [Album(id: 0, name: "유경이의 눈바디", thumbnailURL: "", createdAt: "", albumDescription: "6일간의 기록",
                                pictures: Pictures(lower: [], upper: [], whole: [])),
                          Album(id: 0, name: "유경이의 눈바디", thumbnailURL: "", createdAt: "", albumDescription: "6일간의 기록",
                                                      pictures: Pictures(lower: [], upper: [], whole: [])),
                          Album(id: 0, name: "유경이의 눈바디", thumbnailURL: "", createdAt: "", albumDescription: "6일간의 기록",
                                                      pictures: Pictures(lower: [], upper: [], whole: []))]
    lazy var albumDummy = BehaviorSubject<[Album]>(value: dummy)
}
