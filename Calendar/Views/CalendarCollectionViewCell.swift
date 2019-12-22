//
//  CalendarCollectionViewCell.swift
//  Calendar
//
//  Created by Kautsya Kanu on 16/11/17.
//  Copyright © 2017 Kautsya Kanu. All rights reserved.
//

import Foundation
import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    var date: Date?
	
	// MARK: Elements
	@IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var priorityView: UIView!
    
    override func awakeFromNib() {
        dateLabel.text = ""
        dateLabel.layer.cornerRadius = 15
        dateLabel.layer.masksToBounds = true
        priorityView.layer.cornerRadius = 3
    }
	
	override func prepareForReuse() {
		dateLabel.text = ""
		dateLabel.textColor = UIColor.black
        dateLabel.font = UIFont.systemFont(ofSize: 17)
        dateLabel.backgroundColor = UIColor.white
        priorityView.backgroundColor = UIColor.white
	}
	
    func setCell(date: Date, todo: Todo?) {
        self.date = date
		dateLabel.text = "\(Calendar.current.dateComponents([.day], from: date).day!)"
		
        //Marking Weekends
        let day = Calendar.current.component(.weekday, from: date)
		if(day == 1 || day == 7) {
			dateLabel.textColor = UIColor.red
		}
        
        //Marking Current Date
        if Calendar.current.isDateInToday(date) {
            dateLabel.textColor = UIColor.white
            dateLabel.font = UIFont.boldSystemFont(ofSize: 17)
            dateLabel.backgroundColor = UIColor.red
        }
        
        //Marking Todos Dates
        priorityView.backgroundColor = todo?.priority.getColor() ?? UIColor.white
	}
}
