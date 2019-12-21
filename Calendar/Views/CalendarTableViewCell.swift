//
//  CalendarTableViewCell.swift
//  Calendar
//
//  Created by Kautsya Kanu on 16/11/17.
//  Copyright © 2017 Kautsya Kanu. All rights reserved.
//

import Foundation
import UIKit

protocol CalendarCellProtocol {
    func openTaskFor(date: Date)
}

class CalendarTableViewCell: UITableViewCell {
    
    //MNARK: Properties
    var delegate: CalendarCellProtocol?
    private var todos: [String: Todo] = [:]
    
    // MARK: Elements
    @IBOutlet private weak var monthYearLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
	
	// MARK: Variables
	private var datesOfMonth: [Date]?
	private var offset: Int = 0
	private var numberOfDates: Int = 0
	private var numberOfRows = 0
	
	// MARK: Constants
	private let collectionViewCellHeight: CGFloat = 50.0
	private var collectionViewCellWidth: CGFloat?
	
	override func awakeFromNib() {
		collectionView.dataSource = self
        collectionView.delegate = self
		collectionViewCellWidth = self.frame.width/7
	}
	
	override func prepareForReuse() {
		monthYearLabel.text = ""
		datesOfMonth = []
		DispatchQueue.main.async {
			self.collectionView.reloadData()
		}
	}
	
    func setCell(todos:[String: Todo], datesOfMonth: [Date], numberOfRows: Int) {
        self.todos = todos
		self.datesOfMonth = datesOfMonth
		self.offset = Calendar.current.dateComponents([.weekday], from: datesOfMonth[0]).weekday! - 1
		self.numberOfDates = datesOfMonth.count
		self.numberOfRows = numberOfRows
		let firstDate = datesOfMonth[0]
        let currentMonth = firstDate.convertTo(string: "MMM")
		let year = "\(Calendar.current.component(.year, from: firstDate))"
		self.monthYearLabel.text = currentMonth + " " + year
		DispatchQueue.main.async { [weak self] in
			self?.collectionView.reloadData()
		}
	}
}

//MARK: UICollectionView
extension CalendarTableViewCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return numberOfRows*7
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(CalendarCollectionViewCell.self)", for: indexPath) as! CalendarCollectionViewCell
		DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
			if (indexPath.row >= self.offset) && (indexPath.row < self.numberOfDates+self.offset) {
                let date = self.datesOfMonth![indexPath.row-self.offset]
                let isTodo = self.todos[date.uniqueId()] != nil
				cell.setCell(date: date,
                             isTodo: isTodo)
			}
		}
		return cell
	}
}

extension CalendarTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.row >= offset) && (indexPath.row < numberOfDates+offset) {
            let date = datesOfMonth![indexPath.row-offset]
            delegate?.openTaskFor(date: date)
        }
    }
}

extension CalendarTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewCellWidth!, height: collectionViewCellHeight)
    }
}
