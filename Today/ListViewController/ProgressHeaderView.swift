//
//  ProgressHeaderView.swift
//  Today
//
//  Created by 차유민 on 2023/05/18.
//

import UIKit

class ProgressHeaderView: UICollectionReusableView {
    
    static var elementKind: String { UICollectionView.elementKindSectionHeader }
    
    
    
    var progress: CGFloat = 0 {
        didSet {
            setNeedsLayout()
            heightConstraint?.constant = progress * bounds.height
            UIView.animate(withDuration: 0.2) {
                [weak self] in self?.layoutIfNeeded()
            } // layoutIfNeeded()메서드는 위쪿 및 아래쪽 뷰의 높이 변경을 애니메이션화하여 뷰의 레이아웃을 즉시 업데이트 한다. ㅇ
        }
    }
    
    
    private let upperView = UIView(frame: .zero)
    private let lowerView = UIView(frame: .zero)
    private let containerView = UIView(frame: .zero)
    private var heightConstraint: NSLayoutConstraint?
    private var valueFormat: String {
        NSLocalizedString("%d percent", comment: "progress percentage value format")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareSubView()
        
        isAccessibilityElement = true
        accessibilityLabel = NSLocalizedString("Progress", comment: "Progress view accessibility label")
        accessibilityTraits.update(with: .updatesFrequently)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(corder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        accessibilityValue = String(format: valueFormat, Int(progress * 100.0))
        heightConstraint?.constant = progress * bounds.height
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 0.5 * containerView.bounds.width
    }
    
    func prepareSubView() {
        containerView.addSubview(upperView)
        containerView.addSubview(lowerView)
        addSubview(containerView)
        
        upperView.translatesAutoresizingMaskIntoConstraints = false
        lowerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85).isActive = true
        
        upperView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        upperView.bottomAnchor.constraint(equalTo: lowerView.topAnchor).isActive = true
        lowerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        upperView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        upperView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lowerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        lowerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        heightConstraint = lowerView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
        
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        upperView.backgroundColor = .todayProgressUpperBackground
        lowerView.backgroundColor = .todayProgressLowerBackground
    } // 뷰 계층에 하위 뷰를 추가할 함수
    
    
}
