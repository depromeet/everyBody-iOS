//
//  PopUpActionDelegate.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/17.
//

import UIKit

protocol PopUpActionProtocol: AnyObject {
    func cancelButtonDidTap(_ button: UIButton)
    func confirmButtonDidTap(_ button: UIButton)
    func confirmButtonDidTap(_ button: UIButton, textInfo: String)
}

extension PopUpActionProtocol {
    func confirmButtonDidTap(_ button: UIButton) { }
    func confirmButtonDidTap(_ button: UIButton, textInfo: String) { }
}
