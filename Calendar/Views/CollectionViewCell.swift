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
    
    var date: Date?
	
	// MARK: Elements
	@IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var taskView: UIView!
    
    override func awakeFromNib() {
        dateLabel.text = ""
        taskView.layer.cornerRadius = 3
    }
	
	override func prepareForReuse() {
		dateLabel.text = ""
		dateLabel.textColor = UIColor.black
        dateLabel.font = UIFont.systemFont(ofSize: 17)
        dateLabel.backgroundColor = UIColor.white
	}
	
    func setCell(date: Date, isTodo: Bool) {
        self.date = date
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
        
        taskView.backgroundColor = isTodo ? UIColor.red : UIColor.white
	}
}
