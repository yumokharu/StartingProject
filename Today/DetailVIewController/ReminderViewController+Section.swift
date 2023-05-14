//
//  ReminderViewController+Section.swift
//  Today
//
//  Created by 차유민 on 2023/05/11.
//

import Foundation

extension ReminderViewController {
    enum Section: Int, Hashable {
        case view
        case title
        case date
        case notes
        
        var name: String {
            switch self {
            case .view: return ""
            case .title:
                return NSLocalizedString("Title", comment: "Title section name")
            case .date:
                return NSLocalizedString("Date", comment: "Date section name")
            case .notes:
                return NSLocalizedString("Note", comment: "Note section name")
            }
        }
    }
}
