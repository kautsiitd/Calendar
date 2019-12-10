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
    
    override func awakeFromNib() {
        dateLabel.text = ""
    }
	
	override func prepareForReuse() {
		dateLabel.text = ""
		dateLabel.textColor = UIColor.black
        dateLabel.font = UIFont.systemFont(ofSize: 17)
        dateLabel.backgroundColor = UIColor.white
	}
	
	func setCell(date: Date) {
		dateLabel.text = "\(Calendar.current.dateComponents([.day], from: date).day!)"
		let day = Calendar.current.component(.weekday, from: date)
		if(day == 1 || day == 7) {
			dateLabel.textColor = UIColor.red
		}
        
        if Calendar.current.isDateInToday(date) {
            dateLabel.layer.cornerRadius = 15
            dateLabel.layer.masksToBounds = true
            dateLabel.textColor = UIColor.white
            dateLabel.font = UIFont.boldSystemFont(ofSize: 17)
            dateLabel.backgroundColor = UIColor.red
        }
	}
}
