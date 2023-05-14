//
//  DatePickerContentView.swift
//  Today
//
//  Created by 차유민 on 2023/05/16.
//

import UIKit

class DatePickerContentView: UIView, UIContentView {
    
    struct Configuration: UIContentConfiguration {
        var date = Date.now
        var onChange: (Date) -> Void = { _ in }
        
        func makeContentView() -> UIView & UIContentView {
            return DatePickerContentView(self)
        }
    }
    
    let datepicker = UIDatePicker()
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }
    
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame:  .zero)
        addPinnedSubview(datepicker)
        datepicker.addTarget(self, action: #selector(didPick(_:)), for: .valueChanged)
        datepicker.preferredDatePickerStyle = .inline
       }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        datepicker.date = configuration.date
    }
    
    @objc private func didPick(_ sender: UIDatePicker) {
        guard let configuration = configuration as? DatePickerContentView.Configuration else { return }
        configuration.onChange(sender.date)
    }
}

extension UICollectionViewListCell {
    func datepickerConfiguration() -> DatePickerContentView.Configuration {
        DatePickerContentView.Configuration()
    }
    
}
