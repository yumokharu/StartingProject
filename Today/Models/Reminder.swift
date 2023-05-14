/*
 See LICENSE folder for this sample’s licensing information.
 */

import Foundation

struct Reminder: Equatable, Identifiable {
    var id: String = UUID().uuidString // Foundation의 UUID 구조는 전체적으로 고유한 값을 생성한다. 
    var title: String
    var dueDate: Date
    var notes: String? = nil
    var isComplete: Bool = false
}

extension [Reminder] {
    // Where절을 사용하여 이 확장명 Array where Element == Reminder와 같이 일반 유형을 조건부로 확장할 수도 있음
    func indexOfReminder(withId id: Reminder.ID) -> Self.Index {
        // 특정 reminder의 index를 반환하는 기능을 만듦 // Array.Index는 Int를 위한 type alias이다.
        guard let index = firstIndex(where: { $0.id == id }) else {
            fatalError()
        }
        return index
    }
}



#if DEBUG
extension Reminder {
    static var sampleData = [
        Reminder(
            title: "Submit reimbursement report", dueDate: Date().addingTimeInterval(800.0),
            notes: "Don't forget about taxi receipts"),
        Reminder(
            title: "Code review", dueDate: Date().addingTimeInterval(14000.0),
            notes: "Check tech specs in shared folder", isComplete: true),
        Reminder(
            title: "Pick up new contacts", dueDate: Date().addingTimeInterval(24000.0),
            notes: "Optometrist closes at 6:00PM"),
        Reminder(
            title: "Add notes to retrospective", dueDate: Date().addingTimeInterval(3200.0),
            notes: "Collaborate with project manager", isComplete: true),
        Reminder(
            title: "Interview new project manager candidate",
            dueDate: Date().addingTimeInterval(60000.0), notes: "Review portfolio"),
        Reminder(
            title: "Mock up onboarding experience", dueDate: Date().addingTimeInterval(72000.0),
            notes: "Think different"),
        Reminder(
            title: "Review usage analytics", dueDate: Date().addingTimeInterval(83000.0),
            notes: "Discuss trends with management"),
        Reminder(
            title: "Confirm group reservation", dueDate: Date().addingTimeInterval(92500.0),
            notes: "Ask about space heaters"),
        Reminder(
            title: "Add beta testers to TestFlight", dueDate: Date().addingTimeInterval(101000.0),
            notes: "v0.9 out on Friday")
    ]
}
#endif
