//
//  CalendarViewController.swift
//  Calendar
//
//  Created by Kautsya Kanu on 25/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation
import UIKit

class CalendarViewController: UIViewController {
    //MARK: Constants
    private let calendar = Calendar.current
    private let startYear = 2010
    private let endYear = 2030
    
    //MARK: Properties
    private var cellHeight: CGFloat = 50
    private var cellWidth: CGFloat!
    private var isFirstLayout: Bool = true
    
    //MARK: Variables
    private let numberOfSections: Int
    private var firstDateOfSection: [Date?]
    private var lastDateOfSection: [Date?]
    private var currentDateAt: [[Date?]]
    
    //MARK: Elements
    @IBOutlet private weak var collectionView: UICollectionView!

    required init?(coder: NSCoder) {
        numberOfSections = (endYear-startYear)*12
        firstDateOfSection = [Date?](repeating: nil, count: numberOfSections)
        lastDateOfSection = [Date?](repeating: nil, count: numberOfSections)
        
        let maxItemsInMonth = 42        //As max number of weeks in month is 6 so 6*7=42
        let nilItemsInMonth = [Date?](repeating: nil, count: maxItemsInMonth)
        currentDateAt = [[Date?]](repeating: nilItemsInMonth, count: numberOfSections)
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellWidth = collectionView.frame.width/7
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isFirstLayout {
            isFirstLayout = false
            let indexPath = indexPathOf(date: Date())
            collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        }
    }
}

extension CalendarViewController {
    private func getFirstDateOf(section: Int) -> Date {
        guard let firstDate = firstDateOfSection[section] else {
            let year = startYear + section/12
            let month = section%12 + 1
            let components = DateComponents(calendar: calendar,
                                            year: year, month: month)
            firstDateOfSection[section] = calendar.date(from: components)!
            return firstDateOfSection[section]!
        }
        return firstDate
    }
    
    private func getLastDateOf(section: Int) -> Date {
        guard let lastDate = lastDateOfSection[section] else {
            let firstDate = getFirstDateOf(section: section)
            let components = DateComponents(calendar: calendar, month: 1, day: -1)
            lastDateOfSection[section] = calendar.date(byAdding: components, to: firstDate)!
            return lastDateOfSection[section]!
        }
        return lastDate
    }
    
    private func getCurrentDateOf(indexPath: IndexPath) -> Date? {
        guard let currentDate = currentDateAt[indexPath.section][indexPath.item] else {
            let firstDate = getFirstDateOf(section: indexPath.section)
            let lastDate = getLastDateOf(section: indexPath.section)
            let itemNumber = indexPath.item + 1
            let dateNumber = itemNumber - firstDate.get(component: .weekday) + 1

            if dateNumber < 1 || dateNumber > lastDate.get(component: .day) {
                return nil
            }

            let components = DateComponents(calendar: calendar, day: dateNumber-1)
            currentDateAt[indexPath.section][indexPath.row] = calendar.date(byAdding: components, to: firstDate)
            return currentDateAt[indexPath.section][indexPath.row]
        }
        return currentDate
    }
    
    private func numberOfWeeksIn(section: Int) -> Int {
        let firstDate = getFirstDateOf(section: section)
        return firstDate.numberOfWeeks()
    }
}

//MARK: UICollectionViewDataSource
extension CalendarViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let daysInWeek = 7
        return numberOfWeeksIn(section: section)*daysInWeek
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(CalendarMonthHeaderView.self)", for: indexPath) as? CalendarMonthHeaderView else {
                return UICollectionReusableView()
            }
            DispatchQueue.main.async { [weak self] in
                let date = self?.getFirstDateOf(section: indexPath.section)
                headerView.setView(date: date)
            }
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "\(CalendarCollectionViewCell.self)"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? CalendarCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let currentDate = getCurrentDateOf(indexPath: indexPath) else {
            return cell
        }
        cell.setCell(date: currentDate)
        return cell
    }
}

//MARK: UICollectionViewDelegate
extension CalendarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let date = getCurrentDateOf(indexPath: indexPath) else {
            return
        }
        let taskViewController = TaskViewController(delegate: self, date: date)
        present(taskViewController, animated: true, completion: nil)
    }
}

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

//MARK: TodoProtocol
extension CalendarViewController: TaskVCProtocol {
    func update(date: Date) {
        DispatchQueue.main.async { [weak self] in
            guard let indexPath = self?.indexPathOf(date: date) else { return }
            self?.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func indexPathOf(date: Date) -> IndexPath {
        //As Dec 2019 is One section in CollectionView
        let month = date.get(component: .month)
        let year = date.get(component: .year)
        let section = (year-startYear)*12 + (month-1)
        //If 1Dec 2019 is Tuesday then, itemNumbr is 2(0,1,2,..)
        let firstDate = date.firstDateOfMonth()
        let offset = firstDate.get(component: .weekday) - 1
        let itemNumber = offset + (date.get(component: .day)-1)
        return IndexPath(item: itemNumber, section: section)
    }
}
