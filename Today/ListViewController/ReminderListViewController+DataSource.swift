//
//  ReminderListViewController+DataSource.swift
//  Today
//
//  Created by 차유민 on 2023/05/06.
//

import UIKit

extension ReminderListViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int,Reminder.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Reminder.ID>
    
    var reminderCompletedValue: String {
        NSLocalizedString("Completed", comment: "Reminder completed value")
    }
    var reminderNotCompletedValue: String {
        NSLocalizedString("Not completed", comment: "Reminder not completed value")
    }
    
    private var reminderStore: ReminderStore { ReminderStore.shared }
    
    
    func updateSnapshot(reloading idsThatChanged: [Reminder.ID] = []) {
        // 유저 인터페이스를 업데이트하기 위해서는 reloadItems(-:) 메서드를 이용해서 스냆샷에 reminder가 변경되었음을 알려줘야한다.
        // 매개 변수의 기본값으로 빈 배열을 지정하면 식별자를 제공하지 않고도 viewDidLoad()에서 메서드를 호출할 수 있다.
        let ids = idsThatChanged.filter { id in filteredReminders.contains(where: { $0.id == id })}
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(filteredReminders.map { $0.id })
        // reminders 배열을 사용하여 스냅샷을 구성한다. 식별자 배열을 만들려면 제목 대신 id 속성에 매핑.
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        // 배열이 비지 않았다면 스냅샷에 식별자에 대한 reminders를 다시 로드하도록 지시
        dataSource.apply(snapshot)
        // reminder list view controller의 viewDidLoad() 메서드에서 이전 단계에서 생성한 메서드로 스냇샷 코드를 추출함
        headerView?.progress = progress
        // 머리글의 진행률을 업데이트해줌
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, id: Reminder.ID) {
        let reminder = reminder(withId: id)
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = reminder.title
        contentConfiguration.secondaryText = reminder.dueDate.dayAndTimeText
        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption1)
        // 셀을 목록에 등록하는 것 외에도 셀 등록 방법을 사용하여 표시되는 정보를 구성하고 셀을 포맷함.
        cell.contentConfiguration = contentConfiguration
        // ReminderListViewController 에서 발췌해온 것
        
        var doneButtonConfiguration = doneButtonConfiguration(for: reminder)
        doneButtonConfiguration.tintColor = .todayListCellDoneButtonTint
        cell.accessibilityCustomActions = [doneButtonAccessibilityAction(for: reminder)]
        // cell registration handler에서 cell's accessibilityCustomActions 배열을 사용자 정의 액션의 인스턴스로 설정함
        cell.accessibilityValue = reminder.isComplete ? reminderCompletedValue : reminderNotCompletedValue
        cell.accessories = [
            .customView(configuration: doneButtonConfiguration), .disclosureIndicator(displayed: .always)
        ]
        
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = .todayListCellBackground
        cell.backgroundConfiguration = backgroundConfiguration
        // 제공된 background color asset을 사용해도 외형은 기본 배경색에서 변경되지 않는다. (아직 변경되지 않음)
    }
    
    func reminder(withId id: Reminder.ID) -> Reminder {
        let index = reminders.indexOfReminder(withId: id)
        return reminders[index]
        // reminder 식별자를 수락하고 reminder 배열에서 해당 reminder을 반환하는 메서드
    }
    
    
    func updateReminder(_ reminder: Reminder) {
        do {
            try reminderStore.save(reminder)
            let index = reminders.indexOfReminder(withId: reminder.id)
            reminders[index] = reminder
            // reminder를 수용하고 해당 배열 욧소를 업데이트하는 메서드
        } catch TodayError.accessDenied {
        } catch {
            showError(error)
        }
    }
    
    func completeReminder(withId id: Reminder.ID) {
        // model에서 reminder을 불러오기 위해서 Reminder.ID를 쓴다.
        var reminder = reminder(withId: id) // reminder(withId:)를 호출함으로써 reminder를 불러온다.
        reminder.isComplete.toggle()
        updateReminder(reminder)
        updateSnapshot(reloading: [id])
        // 스냅샷을 업데이트 할 때마다 reminder의 식별자를 넘겨줌 (따라서 인터페이스가 업데이트 됨)
    }
    
    func addReminder(_ reminder: Reminder) {
        var reminder = reminder
        do { // reminder를 저장하기 위한 것
            let idFromStore = try reminderStore.save(reminder)
            reminder.id = idFromStore // 유입되는 식별자를 reminder 변수에 할당해줌
            reminders.append(reminder)
        } catch TodayError.accessDenied {
        } catch {
            showError(error)
        }
    } // Done 버튼을 눌렀을때 새로운 reminder를 저장하기 위해 사용한다. 
    
    func deleteReminder(withId id: Reminder.ID) {
        do {
            try reminderStore.remove(with: id)
            let index = reminders.indexOfReminder(withId: id)
            reminders.remove(at: index)
        } catch TodayError.accessDenied {
        } catch {
            showError(error)
        }
            }
    
    func prepareReminderStore() {
        Task {
            do {
                try await reminderStore.requestAccess()
                reminders = try await reminderStore.readAll()
                NotificationCenter.default.addObserver(self, selector: #selector(eventStoreChanged(_:)), name: .EKEventStoreChanged, object: nil)
            } catch TodayError.accessDenied, TodayError.accessRestricted {
                #if DEBUG
                reminders = Reminder.sampleData
                #endif // 샘플 데이터를 제공하면 EventKit 데이터를 사용할 수 없을 때 앱이 데모 모드에서 작동할 수 있다.
            } catch {
                showError(error)
            }
            updateSnapshot()
        } // Task를 생성하여 비동기적으로 실행되는 새 작업 단위를 생성한다.
    }
    
     func reminderStoreChanged() {
        Task {
            reminders = try await reminderStore.readAll()
            updateSnapshot()
        }
    }
    
    private func doneButtonAccessibilityAction(for reminder: Reminder) -> UIAccessibilityCustomAction {
        let name = NSLocalizedString("Toggle completion", comment: "Reminder done button accessibility label")
        // VoiceOver는 개체에 대해 작업을 사용할 수 있을 때 사용자에게 경고한다. 사용자가 옵션을 듣기로 결정하며 VoiceOver는 각 작업의 이름을 읽는다.
        let action = UIAccessibilityCustomAction(name: name) { [weak self] action in
            self?.completeReminder(withId: reminder.id)
            return true
        }
        // 이전 단계에서 정의한 이름을 사용하여 UIAccessibilityCustomAction을 생성함. action Handler 클로져에서 true를 반환한다.
        // 기본적으로 closure은 내부에서 사용하는 외부 값에 대한 강한 참조를 생성한다. view controller에 대한 약한 참조를 지정해주면 강한참조 싸이클을 해결할 수 있다.
        return action
    }
    
    
    
    private func doneButtonConfiguration(for reminder: Reminder)
    -> UICellAccessory.CustomViewConfiguration
    {
        let symbolName = reminder.isComplete ? "circle.fill" : "circle"
        // reminder.isComplete 상태라면 "circle.fill"을, 아니라면 "circle"을 출력
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
        let button = ReminderDoneButton()
        button.addTarget(self, action: #selector(didPressDoneButton(_:)), for: .touchUpInside)
        button.id = reminder.id
        button.setImage(image, for: .normal)
        return UICellAccessory.CustomViewConfiguration(customView: button, placement: .leading(displayed: .always))
        // 이 구성 이니셜라이저를 사용하여 셀 엑세서리를 셀의 내용 보기를 외부에 있는 셀의 앞 가장자리 또는 뒤 가장자리에 표시할지 여부를 정의할 수 있음
    }
    
    
}
