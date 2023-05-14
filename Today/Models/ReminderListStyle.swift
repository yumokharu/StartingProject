//
//  ReminderListStyle.swift
//  Today
//
//  Created by 차유민 on 2023/05/17.
//

import Foundation

enum ReminderListStyle: Int {
    case today
    case future
    case all
    
    var name: String {
        switch self {
        case .today:
            return NSLocalizedString("Today", comment: "Today style name")
        case .future:
            return NSLocalizedString("Future", comment: "Future style name")
        case .all:
            return NSLocalizedString("All", comment: "All style name")
        }
    }
    
    func shouldInclude(date: Date) -> Bool {
        let isInToday = Locale.current.calendar.isDateInToday(date) // isInToday 값은 호출자가 함수에 전달한 날짜가 오늘이면 참, 아니면 거짓
        switch self {
        case .today:
            return isInToday
        case .future:
            return (date > Date.now) && !isInToday
        case .all:
            return true
        }
    } // reminderlistviewcontroller는 사용자가 선택한 목록 스타일과 일치하는 마감일이 있는 reminder만 표시함
}
