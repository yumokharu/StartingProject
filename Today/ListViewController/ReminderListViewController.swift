/*
 See LICENSE folder for this sample’s licensing information.
 */

import UIKit

class ReminderListViewController: UICollectionViewController {
    var dataSource: DataSource!
    var reminders: [Reminder] = []
    // 이 속성을 사용하여 스냅샷 및 collection view 셀을 구성할 것
    // reminders 인스턴스의 배열을 저장하는 속성을 추가, 샘플 데이터를 사용해서 배열을 초기화한다.
    var listStyle: ReminderListStyle = .today
    var filteredReminders: [Reminder] {
        return reminders.filter { listStyle.shouldInclude(date: $0.dueDate) }.sorted { $0.dueDate < $1.dueDate }
    } // filter(_:) 메서드는 컬렉션을 루프하고 조건을 만족하는 요소만 포함하는 배열을 반환한다.
    
    let listStyleSegmentControl = UISegmentedControl(items: [
        ReminderListStyle.today.name, ReminderListStyle.future.name, ReminderListStyle.all.name
    ])
    var headerView: ProgressHeaderView?
    var progress: CGFloat {
        let chunkSize = 1.0 / CGFloat(filteredReminders.count)
        let progress = filteredReminders.reduce(0.0) {
            let chunk = $1.isComplete ? chunkSize : 0
            return $0 + chunk
        } // 초기값은 0. 진행률을 계산하려면 사용자가 완료하는 각 주의사항에 대한 청크 크기($1)를 이전에 누적된 값에 추가함
        return progress
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        collectionView.backgroundColor = .todayGradientFutureBegin
        
        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout

        
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)

        dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        let headerResitration = UICollectionView.SupplementaryRegistration(elementKind: ProgressHeaderView.elementKind, handler: supplementaryResitrationHandler)
        dataSource.supplementaryViewProvider = { supplementaryView, elementKind, indexPath in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerResitration, for: indexPath)
        } // 이 클로저는 diffable data source에서 보조 헤더 뷰를 구성하고 반환한다.
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPresseAddButton(_:)))
        addButton.accessibilityLabel = NSLocalizedString("Add reminder", comment: "Add button accessibility label")
        
        navigationItem.rightBarButtonItem = addButton
        
        listStyleSegmentControl.selectedSegmentIndex = listStyle.rawValue
        // swift는 자동으로 각 대소문자에 0부터 시작하는 정수 값을 할당한다. selected Segment인덱스는 선택한 세그먼트의 인덱스 번호임
        listStyleSegmentControl.addTarget(self, action: #selector(didChangeListStyle(_:) ), for: .valueChanged)
        navigationItem.titleView = listStyleSegmentControl
        
        if #available(iOS 16, *) {
            navigationItem.style = .navigator
        }
        
        updateSnapshot()

        collectionView.dataSource = dataSource
        
        prepareReminderStore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshBackground()
    } // 배경을 표시하기 위해선 뷰라이프사이클에서 배경을 새로 고쳐줘야한다. 
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let id = filteredReminders[indexPath.item].id
        // 이 인덱스 경로와 연결된 reminder 식별자를 불러와서 id 라고 명명된 상수에 할당한다.
        // index의 항목 요소는 Int이기 떄문에 이를 배열 인덱스로 사용하여 적절한 reminder를 찾아올 수 있다.
        pushDetailViewForReminder(withId: id)
        // 이 메서드는 내비게이션 스택에 디테일 뷰컨드롤러를 추가해준다. 디테일 뷰는 제공되 식별자에 대한 reminder 세부정보가 표시된다. 그리고 BACK 버튼이 내비게이션 바에 자동으로 생성된다.
        return false
    }
    // 사용자가 선택한 항목을 누른 항목이 표시되지 않기 떄문에 false를 반환한다. 대신 해당 목록 항목에 대한 세부 정보 보기로 전환된다.
    
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard elementKind == ProgressHeaderView.elementKind,
              let progressView = view as? ProgressHeaderView
        else {
            return
        }
        progressView.progress = progress
    } // 시스템은 컬렉션 보기가 보조 보기를 표시하려고 할 떄 이 메서드를 호출한다.
    
    func refreshBackground() {
        collectionView.backgroundView = nil
        let backgroundView = UIView()
        let gradientLayer = CAGradientLayer.gradientLayer(for: listStyle, in: collectionView.frame)
        backgroundView.layer.addSublayer(gradientLayer)
        collectionView.backgroundView = backgroundView
    }
    
    
    func pushDetailViewForReminder(withId id: Reminder.ID) {
        let reminder = reminder(withId: id)
        let viewController = ReminderViewController(reminder: reminder) {[weak self] reminder in
            self?.updateReminder(reminder)
            self?.updateSnapshot(reloading: [reminder.id])
        }
        navigationController?.pushViewController(viewController, animated: true)
        // viewController를 네비게이션 컨트롤러 스택에 넣음
        // 뷰 컨트롤러가 현재 내비게이션 컨트롤러에 내장되어 있는 경우 내비게이션 컨트롤러에 대한 참조는 옵셔널 내비게이션 컨트롤러 속성에 저장된다.
        
    }
    // reminder 식별자에 접근하기 위한 함수임
    

    func showError(_ error: Error) {
        let alertTitle = NSLocalizedString("Error", comment: "Error alert title")
        let alert = UIAlertController(title: alertTitle, message: error.localizedDescription, preferredStyle: .alert)
        let actionTitle = NSLocalizedString("OK", comment: "Alert OK button title")
        alert.addAction(
            UIAlertAction(title: actionTitle, style: .default,
                          handler: { [weak self] _ in
                              self?.dismiss(animated: true)
                          })) // 사용자가 메시지를 읽은 후 확인 버튼을 눌러 경고를 해제할 수 있다.
        present(alert, animated: true, completion: nil)
    }
    
    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listConfiguration.headerMode = .supplementary
        listConfiguration.showsSeparators = false
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listConfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath, let id = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        let deleteActionTitle = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActionTitle) {[weak self] _, _, completion in
            self?.deleteReminder(withId: id)
            self?.updateSnapshot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func supplementaryResitrationHandler(progressView: ProgressHeaderView, elementKind: String, indexpath: IndexPath) {
        headerView = progressView
    }
    
}
