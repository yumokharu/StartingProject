//
//  ReminderStore.swift
//  Today
//
//  Created by 차유민 on 2023/05/22.
//

import EventKit
import Foundation

final class ReminderStore {
    static let shared = ReminderStore()
    
    private var ekStore = EKEventStore()
    
    var isAvailable: Bool {
        EKEventStore.authorizationStatus(for: .reminder) == .authorized
    }
    
    func requestAccess() async throws {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .authorized:
            return
        case .restricted:
            throw TodayError.accessRestricted
        case .notDetermined:
            let accessGranted = try await ekStore.requestAccess(to: .reminder)
            guard accessGranted else {
                throw TodayError.accessDenied
            }
        case .denied:
            throw TodayError.accessDenied
        @unknown default:
            throw TodayError.unknown
        }
    }
    
    func readAll() async throws -> [Reminder] {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        
        let predicate = ekStore.predicateForReminders(in: nil) // 결과를 리마인더 항목으로만 좁힌다. 선택한 경우 결과를 특정 캘린더의 리아인더로 좁일 수 있다.
        let ekReminders = try await ekStore.reminders(matching: predicate)
        // await 키워드는 결과를 사용할 수 있을때까지 작업이 일시중단됨을 나타낸다. 이때 작업이 다시 시작되고 결과를 ekReminders 상수에 할당한다.
        let reminders: [Reminder] = try ekReminders.compactMap { ekReminder in
            do {
                return try Reminder(with: ekReminder)
            } catch TodayError.reminderHasNoDueDate {
                return nil
            }
        } // compactMap(_:)은 필터와 맵 역할을 모두 수행하여 원본 컬렉션에서 항목을 삭제할 수 있다.
        return reminders
    }
    
    
    @discardableResult // 결과값을 버릴 수 있는 속성 (return 값을 사용하지 않아도 warning 메세지를 나오지 않도록 설정하는 것)
    func save(_ reminder: Reminder) throws -> Reminder.ID {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let ekReminder: EKReminder
        do {
            ekReminder = try read(with: reminder.id)
        } catch {
            ekReminder = EKReminder(eventStore: ekStore)
        } // 해당 식별자가 있는 주의사하을 찾지 못했다고 해서 오류가 발생한 것이 아닌 사용자가 새 주의사항을 저장하고 있음을 나타낸다...???
        ekReminder.update(using: reminder, in: ekStore)
        try ekStore.save(ekReminder, commit: true)
        return ekReminder.calendarItemIdentifier
    }
    
    func remove(with id: Reminder.ID) throws {
        guard isAvailable else {
            throw TodayError.accessDenied
        }
        let ekReminder = try read(with: id)
        try ekStore.remove(ekReminder, commit: true)
    }
    
    
    private func read(with id: Reminder.ID) throws -> EKReminder {
        guard let ekReminder = ekStore.calendarItem(withIdentifier: id) as? EKReminder else {
            throw TodayError.failedReadingCalendarItem
        } // 일치하는 캘린더 항목을 검색하여 EKReminder로 캐스팅하는 가드문을 추가함. 스토어에서 항목을 찾을 수 없을 때는 에러를 던져서 에러처리
        return ekReminder
    }
    
}
