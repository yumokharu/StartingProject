//
//  Reminder+EKReminder.swift
//  Today
//
//  Created by 차유민 on 2023/05/22.
//

import EventKit
import Foundation

extension Reminder {
    init(with ekReminder: EKReminder) throws {
        guard let dueDate = ekReminder.alarms?.first?.absoluteDate else {
            throw TodayError.reminderHasNoDueDate
        }
        id = ekReminder.calendarItemIdentifier // EventKir는 모든 reminder에 고유한 식별자를 제공한다.
        title = ekReminder.title
        self.dueDate = dueDate
        notes = ekReminder.notes
        isComplete = ekReminder.isCompleted
    }
}
