//
//  String+2DigitFormat.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/20.
//

import Foundation

extension String {
    
    func convertTo2Digit() -> String {
        if self.count < 2 {
            return "0\(self)"
        } else {
            return self
        }
    }
    
}
