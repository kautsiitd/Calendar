//
//  CollectionViewCell.swift
//  Calendar
//
//  Created by Kautsya Kanu on 16/11/17.
//  Copyright © 2017 Kautsya Kanu. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {
	
	// MARK: Elements
	@IBOutlet fileprivate weak var dateLabel: UILabel!
	
	override func prepareForReuse() {
		dateLabel.text = ""
		dateLabel.textColor = UIColor.black
	}
	
	func setCell(date: Date) {
		dateLabel.text = "\(Calendar.current.dateComponents([.day], from: date).day!)"
		let day = Calendar.current.component(.weekday, from: date)
		if(day == 1 || day == 7) {
			dateLabel.textColor = UIColor.red
		}
	}
}
