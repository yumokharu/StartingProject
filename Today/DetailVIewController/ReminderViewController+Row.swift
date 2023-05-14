//
//  ReminderViewController+Row.swift
//  Today
//
//  Created by 차유민 on 2023/05/06.
//

import UIKit

extension ReminderViewController {
    enum Row: Hashable {
        case header(String) // 연관된 값이 머리글 제목으로 표시됨
        case date
        case notes
        case time
        case title
        case editableDate(Date)
        case editableText(String?)
        
        var imageName: String? {
            switch self {
            case .date: return "calendar.circle"
            case .notes: return "square.and.pencil"
            case .time: return "clock"
            default: return nil
            // 각 케이스에 알맞는 SF Symbol을 반환
            }
        }
        
        var image: UIImage? {
            guard let imageName = imageName else { return nil } // imageName 옵셔널 바인딩 해줌
            let configuration = UIImage.SymbolConfiguration(textStyle: .headline)
            return UIImage(systemName: imageName, withConfiguration: configuration)
            // 이미지 이름을 기준으로 이미지를 반환하는 계산된 속성 이미지를 추가,,
            // Add a computed property named image that returns an image based on the image name.
        }
        
        var textStyle: UIFont.TextStyle {
            switch self {
            case .title: return .headline
            default: return .subheadline
            // 헤드라인 글꼴을 사용하여 각 reminder의 제목을 강조함
            }
        }
    }
}
