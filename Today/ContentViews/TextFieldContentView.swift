//
//  TextFieldContentView.swift
//  Today
//
//  Created by 차유민 on 2023/05/14.
//

import UIKit

class TextFieldContentView: UIView, UIContentView {
    
    struct Configuration: UIContentConfiguration {
        var text: String? = ""
        var onChange: (String) -> Void = { _ in }
        
        func makeContentView() -> UIView & UIContentView {
            return TextFieldContentView(self)
        }
    }
    
    
    let textField = UITextField()
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        } // 구성 속성에 새 구성 매서드를 호출하는 didSet 관찰를 추가함
    }
    
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        addPinnedSubview(textField, insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        textField.addTarget(self, action: #selector(didChange(_:)), for: .editingChanged)
        textField.clearButtonMode = .whileEditing
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        // 사용자 정의 이니셜라이져를 구현하는 UIView 하위 클래스는 필수 init(cdoer:) 이니셜라이져도 구현해야한다.
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        textField.text = configuration.text
    }
    
    @objc private func didChange(_ sender: UITextField) {
        guard let configuration =
                configuration as? TextFieldContentView.Configuration else { return }
        configuration.onChange(textField.text ?? "")
    }
}


extension UICollectionViewListCell {
    func textFieldConfiguration() -> TextFieldContentView.Configuration {
        TextFieldContentView.Configuration()
    }
}
