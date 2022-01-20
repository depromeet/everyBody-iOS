//
//  PrivacyPolicyViewController.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/21.
//

import UIKit

import SnapKit
import WebKit

class PrivacyPolicyViewController: BaseViewController {

    weak var webKitView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()
        setWebkit()
        setConstraint()
        loadURL()
    }
    
    func initNavigationBar() {
        navigationController?.initNaviBarWithBackButton()
        title = "개인정보 처리방침"
    }
    
    func setWebkit() {
        let webConfiguration = WKWebViewConfiguration()
        let webKitView: WKWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webKitView = webKitView
    }
    
    func setConstraint() {
        guard let webKitView = webKitView else {
            return
        }

        view.addSubview(webKitView)
        
        webKitView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }

    func loadURL() {
        if let url = URL(string: "https://pointy-wakeboard-3b9.notion.site/112eea33354042f3a0df8cadd5aeae69") {
            let urlRequest = URLRequest(url: url)
            webKitView?.load(urlRequest)
        } 
    }
}
