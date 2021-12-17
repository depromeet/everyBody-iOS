//
//  ViewFinder.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/14.
//

import UIKit
import AVFoundation

struct ViewFinder {
    
    var camera: Camera
    var height: CGFloat
    
    func makeUIView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Constant.Size.screenWidth, height: height))
        view.backgroundColor = .black

        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        return view
    }
    
}
