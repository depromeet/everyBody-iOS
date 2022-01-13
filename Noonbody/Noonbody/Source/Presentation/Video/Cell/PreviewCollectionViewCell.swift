//
//  PreviewCollectionViewCell.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/11.
//

import UIKit

protocol DeleteButtonDelegate: AnyObject {
    func deleteButtonDidTap(identifier: ImageInfo)
}

class PreviewCollectionViewCell: UICollectionViewCell {
 
    private let imageView = UIImageView().then {
        $0.image = Asset.Image.sample.image
    }
    private lazy var xButton = UIButton().then {
        $0.setImage(Asset.Image.close.image, for: .normal)
        $0.addTarget(self, action: #selector(deleteButtonDidTap), for: .touchUpInside)
    }
    var identifiter: ImageInfo = ImageInfo(imageKey: "", imageURL: "")
    weak var delegate: DeleteButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setConstraints()
        clipsToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints() {
        addSubviews(imageView, xButton)
        
        imageView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(4)
            $0.leading.bottom.equalToSuperview()
        }
        
        xButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.width.height.equalTo(18)
        }
    }
    
    func setImage(named imageName: String) {
        imageView.setImage(with: imageName)
    }
    
    func setSelectedUI() {
        imageView.makeRoundedWithBorder(radius: 4, color: Asset.Color.keyPurple.color.cgColor, borderWith: 2)
        xButton.setImage(Asset.Image.selectedClose.image, for: .normal)
    }
    
    func setUnselectedUI() {
        imageView.makeRoundedWithBorder(radius: 4, color: UIColor.clear.cgColor)
        xButton.setImage(Asset.Image.close.image, for: .normal)
    }
    
    @objc private func deleteButtonDidTap() {
        delegate?.deleteButtonDidTap(identifier: self.identifiter)
    }
}
