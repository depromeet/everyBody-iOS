//
//  CircleProgressView.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/18.
//

import UIKit

import SnapKit
import Lottie

class CircleProgressView: UIView {

    let shapeLayer = CAShapeLayer()
    private let completedView = AnimationView(name: "downloadCompleted")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        snp.makeConstraints {
            $0.width.height.equalTo(68)
        }
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        let circularPath = UIBezierPath(arcCenter: .zero,
                                        radius: 34,
                                        startAngle: 0,
                                        endAngle: 2 * .pi,
                                        clockwise: true)
        
        let backLayer = CAShapeLayer()
        backLayer.path = circularPath.cgPath
        backLayer.strokeColor = Asset.Color.gray30.color.cgColor
        backLayer.lineWidth = 5
        backLayer.fillColor = UIColor.clear.cgColor
        backLayer.lineCap = .round
        backLayer.position = center
        layer.addSublayer(backLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = Asset.Color.keyPurple.color.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.strokeEnd = 0
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.position = center
        shapeLayer.transform = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func setCompletedView() {
        addSubview(completedView)
        completedView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.edges.equalToSuperview()
        }
        completedView.play()
    }
    
    func removeCompletedView() {
        completedView.removeFromSuperview()
    }
    
}
