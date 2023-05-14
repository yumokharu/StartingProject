//
//  CAGradientLayer+ListStyle.swift
//  Today
//
//  Created by 차유민 on 2023/05/22.
//

import UIKit

extension CAGradientLayer {
    static func gradientLayer(for style: ReminderListStyle, in frame: CGRect) -> Self {
        let layer = Self()
        layer.colors = layer.colors(for: style)
        layer.frame = frame
        
        return layer
    }
    private func colors(for style: ReminderListStyle) -> [CGColor] {
        let beginColor: UIColor
        let endColor : UIColor
        
        switch style {
        case .all:
            beginColor = .todayGradientAllBegin
            endColor = .todayGradientAllEnd
        case .future:
            beginColor = .todayGradientFutureBegin
            endColor = .todayGradientFutureEnd
        case .today:
            beginColor = .todayGradientTodayBegin
            endColor = .todayGradientTodayEnd
        }
        return [beginColor.cgColor, endColor.cgColor]
    }
    
}
