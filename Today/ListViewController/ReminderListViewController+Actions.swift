//
//  ReminderListViewController+Actions.swift
//  Today
//
//  Created by 차유민 on 2023/05/06.
//

import UIKit
// reminder identifier를 저장하는 custom button을 만들고 사용자가 버튼을 누를 때 호출할 기능을 정의했음,, 

extension ReminderListViewController {
    @objc func eventStoreChanged(_ notification: NSNotification) {
        reminderStoreChanged()
    }
    
    
    @objc func didPressDoneButton(_ sender: ReminderDoneButton) {
        guard let id = sender.id else { return }
        completeReminder(withId: id)
    }
    
    @objc func didPresseAddButton(_ sender: UIBarButtonItem) {
        let reminder = Reminder(title: "", dueDate: Date.now)
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            self?.addReminder(reminder)
            self?.updateSnapshot()
            self?.dismiss(animated: true)
        }
        viewController.isAddingNewReminder = true
        viewController.setEditing(true, animated: false)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancelAdd(_: )))
        viewController.navigationItem.title = NSLocalizedString("Add Reminder", comment: "Add Reminder view controller title")
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
    
    
    
    @objc func didCancelAdd(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc func didChangeListStyle(_ sender: UISegmentedControl ) {
        listStyle = ReminderListStyle(rawValue: sender.selectedSegmentIndex) ?? .today
        updateSnapshot()
        refreshBackground()
    }
    
    
    
}

