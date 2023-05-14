//
//  UIView+pinnedSubview.swift
//  Today
//
//  Created by 차유민 on 2023/05/14.
//

import UIKit

extension UIView {
    func addPinnedSubview(_ subview: UIView, height: CGFloat? = nil, insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)) {
        addSubview(subview)
        // UIView의 addsubview(_:) 메서드는 Subview를 Superview의 계층 맨 아래에 추가한다.
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top).isActive = true
        subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1.0 * insets.right).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.0 * insets.bottom).isActive = true
        if let height {
            subview.heightAnchor.constraint(equalToConstant: height).isActive = true
        // 호출자가 높이를 명시적으로 지정하는 경우 하위 보기를 해당 높이로 제한한다. 하위뷰는 수퍼 뷰의 상단과 하단에 고정되어 있으므로 하위 뷰의 높이를 조정하면 하위 뷰의 높이도 조정된다. 
        }
    }
}
