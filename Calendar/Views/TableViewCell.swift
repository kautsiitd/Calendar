//
//  TableViewCell.swift
//  Calendar
//
//  Created by Kautsya Kanu on 16/11/17.
//  Copyright © 2017 Kautsya Kanu. All rights reserved.
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {
	
	// MARK: Variables
	fileprivate var datesOfMonth: [Date]?
	fileprivate var offset: Int = 0
	fileprivate var numberOfDates: Int = 0
	fileprivate var numberOfRows = 0
	
	// MARK: Constants
	fileprivate var collectionViewCellHeight: CGFloat?
	fileprivate var collectionViewCellWidth: CGFloat?
	
	// MARK: Elements
	@IBOutlet fileprivate weak var monthYearLabel: UILabel!
	@IBOutlet fileprivate weak var weekLabelsView: UIView!
	@IBOutlet fileprivate weak var collectionView: UICollectionView!
	
	override func awakeFromNib() {
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionViewCellHeight = 50.0
		collectionViewCellWidth = self.frame.width/7
	}
	
	override func prepareForReuse() {
		monthYearLabel.text = ""
		datesOfMonth = []
	}
	
	func setCell(datesOfMonth: [Date], numberOfRows: Int) {
		self.datesOfMonth = datesOfMonth
		self.offset = Calendar.current.dateComponents([.weekday], from: datesOfMonth[0]).weekday! - 1
		self.numberOfDates = datesOfMonth.count
		self.numberOfRows = numberOfRows
		let firstDate = datesOfMonth[0]
		let currentMonth = firstDate.getMonthName()
		let year = "\(Calendar.current.component(.year, from: firstDate))"
		self.monthYearLabel.text = currentMonth + " " + year
		DispatchQueue.main.async {
			self.collectionView.reloadData()
		}
	}
}

extension TableViewCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return numberOfRows*7
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
		DispatchQueue.main.async {
			if (indexPath.row >= self.offset) && (indexPath.row < self.numberOfDates+self.offset) {
				cell.setCell(date: self.datesOfMonth![indexPath.row-self.offset])
			}
		}
		return cell
	}
}

extension TableViewCell: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionViewCellWidth!, height: collectionViewCellHeight!)
	}
}
