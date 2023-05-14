//
//  ReminderViewController.swift
//  Today
//
//  Created by 차유민 on 2023/05/06.
//

import UIKit

class ReminderViewController: UICollectionViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    // 데이터 소스는 섹션 번호에 Int 인스턴스를 사용하고 목록 행에 대해서는 이전 섹션에서 정의한 사용자 지정 열거형의 인스턴스를 사용한다.
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
  
    var reminder: Reminder {
        didSet {
            onChange(reminder)
        }
    }
    
    var workingReminder: Reminder // 사용자가 편집 내용을 저장하거나 삭제하도록 선택할 때까지 편집 내용을 저장함
    var isAddingNewReminder = false // 사용자가 새 reminder를 추가할 것인지 또는 기존 주의사항을 보거나 편집할 것인지 나타냄
    var onChange: (Reminder) -> Void
    private var dataSource: DataSource!
    
    init(reminder: Reminder, onChange: @escaping (Reminder) -> Void) {
        self.reminder = reminder
        self.workingReminder = reminder
        self.onChange = onChange
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        listConfiguration.showsSeparators = false
        listConfiguration.headerMode = .firstItemInSection
        // 목록 구성에서 구분 기호를 사용하지 않도록 설정하여 목록 셀 사이의 줄을 제거
        let listLayout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        super.init(collectionViewLayout: listLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Always initialize ReminderViewController using init(reminder:)")
        // init(coder:)를 포함하면 요구 사항을 충족할 수 있음. Today은 코드로만 뷰컨트롤러를 만들기 떄문에 이 앱에서는 이 이니셜라이저를 사용하지 않는다.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Row) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            // 재사용 가능한 셀의 대기열을 해제하는 새 데이터 소스를 생성하고 결과를 dataSource에 할당한다.
        }
        
        if #available(iOS 16, *) {
            navigationItem.style = .navigator
        }
        
        navigationItem.title = NSLocalizedString("Reminder", comment: "Reminder view controller title")
        navigationItem.rightBarButtonItem = editButtonItem
        
        updateSnapshotForViewing()
    }
    // 뷰 컨트롤러의 수명 주기 방법을 재정의하는 경우 먼저 사용자 지정 작업 전에 슈퍼 클래스에서 자체 작업을 수행할 수 있는 기회를 준다.
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            prepareForEditing()
        } else {
            if isAddingNewReminder {
                onChange(workingReminder)
            } else {
                prepareForViewing()
            }
        }
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        let section = section(for: indexPath)
        switch (section, row) {
        case (_, .header(let title)):
            cell.contentConfiguration = headerConfiguration(for: cell, with: title)
        case (.view, _):
            cell.contentConfiguration = defaultConfiguration(for: cell, at: row)
            // 사용자 지정 구성을 collection view cell에 제공해줌
        case (.title, .editableText(let title)):
            cell.contentConfiguration = titleConfiguration(for: cell, with: title)
        case(.date, .editableDate(let date)):
            cell.contentConfiguration = dateConfiguration(for: cell, with: date)
        case(.notes, .editableText(let notes)):
            cell.contentConfiguration = noteConfiguration(for: cell, with: notes)
        default:
            fatalError("Unexpected combination of section and row.")
        } // 튜플을 사용하여 섹션 및 행 값을 스위치 문에서 사용할 수 있는 단일 복합 값으로 그룹화할 수 있다.
        // 구성을 할당하면 사용자 인터페이스가 업데이트 되어 변경 사항이 반영된다. 
        cell.tintColor = .todayPrimaryTint
    }
    
    @objc func didCancelEdit() {
        workingReminder = reminder
        setEditing(false, animated: true)
    }
    
    private func prepareForEditing() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(didCancelEdit))
            updateSnapshotForEditing()
    }
    
    private func updateSnapshotForEditing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.title, .date, .notes])
        snapshot.appendItems(
            [.header(Section.title.name), .editableText(reminder.title)], toSection: .title)
        snapshot.appendItems([.header(Section.date.name), .editableDate(reminder.dueDate)], toSection: .date)
        snapshot.appendItems([.header(Section.notes.name), .editableText(reminder.notes)], toSection: .notes)
        dataSource.apply(snapshot)
    }
    
    private func prepareForViewing() {
        navigationItem.leftBarButtonItem = nil 
        if workingReminder != reminder {
            reminder = workingReminder
        } // 사용자가 변경한 경우에만 작업 값을 주의사항 속성에 복사해야 한다. 
        updateSnapshotForViewing()
    }
    
    
    
    private func updateSnapshotForViewing() {
        var snapshot = Snapshot()
        snapshot.appendSections([.view])
        snapshot.appendItems([Row.header(""), Row.title, Row.notes, Row.date, Row.time], toSection: .view)
        dataSource.apply(snapshot)
        // 스냅샷을 적용하면 스냅샷의 데이터와 스타일이 반영되도록 사용자 인터페이스가 업데이트된다.
    }
    
    private func section(for indexPath: IndexPath) -> Section {
        let sectionNumber = isEditing ? indexPath.section + 1 : indexPath.section
        guard let section = Section(rawValue: sectionNumber) else {
            fatalError("Unable to find matching section")
            // raw value로 정의된 열거형에는 제공된 원시값이 정의된 범위를 벗어나는 경우 0을 반환함,, 그래서 옵셔널 바인딩 해준듯
        }
        return section
    } // view mode에서는 모든 항목이 세션 0에 표시된다. editing mode에서는 제목, 날짜 및 노트가 각각 섹션 1,2,3으로 구분된다.
}
