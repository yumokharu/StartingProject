//
//  RemiderViewController+CellConfiguration.swift
//  Today
//
//  Created by 차유민 on 2023/05/14.
//

import UIKit

extension ReminderViewController {
    func defaultConfiguration(for cell: UICollectionViewListCell , at row: Row) -> UIListContentConfiguration {
        var contentConfiguration = cell.defaultContentConfiguration() // 셀의 기본 구성을 지정해줌
        contentConfiguration.text = text(for: row)
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: row.textStyle)
        contentConfiguration.image = row.image
        return contentConfiguration
    }
    
    func headerConfiguration(for cell: UICollectionViewListCell, with title: String) -> UIListContentConfiguration {
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = title
        return contentConfiguration
    }
    
    func titleConfiguration(for cell: UICollectionViewListCell, with title: String?) -> TextFieldContentView.Configuration {
        var contentConfiguration = cell.textFieldConfiguration()
        contentConfiguration.text = title
        contentConfiguration.onChange = { [weak self] title in
            self?.workingReminder.title = title
        }
        return contentConfiguration
    }
    
    func dateConfiguration(for cell: UICollectionViewListCell, with date: Date) -> DatePickerContentView.Configuration {
        var contentConfiguration = cell.datepickerConfiguration()
        contentConfiguration.date = date
        contentConfiguration.onChange = { [weak self] dueDate in
            self?.workingReminder.dueDate = dueDate
        }
        return contentConfiguration
    }
    
    func noteConfiguration(for cell: UICollectionViewListCell, with notes: String?) -> TextViewContentView.Configuration {
        var contentConfiguration = cell.textViewConfiguration()
        contentConfiguration.text = notes
        contentConfiguration.onChange = { [weak self] notes in
            self?.workingReminder.notes = notes
        }
        return contentConfiguration
    }
    
    
    func text(for row: Row) -> String? {
        switch row {
        case  .date: return reminder.dueDate.dayText
        case .notes: return reminder.notes
        case .time: return reminder.dueDate.formatted(date: .omitted, time: .shortened)
        case .title: return reminder.title
        default: return nil
            // if문으로 선언할 수도 있지만, 열거형으로 선언 해놓는 것이 수정 및 추가하기 편하기 떄문에 열거형으로 선언함
        }
    }
}
       
