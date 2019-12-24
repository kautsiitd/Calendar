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
    
    //MARK: Constants
        //Fonts
    private let normalDateFont = UIFont.systemFont(ofSize: 17)
    private let currentDateFont = UIFont.boldSystemFont(ofSize: 17)
        //Colors
    private let normalDateColor = UIColor.black
    private let weekendDateColor = UIColor.red
    private let currentDateColor = UIColor.white
    private let normalDateBackgroundColor = UIColor.white
    private let currentDateBackgroundColor = UIColor.red
    
    override func awakeFromNib() {
        dateLabel.text = ""
        dateLabel.layer.cornerRadius = dateLabel.frame.width/2
        dateLabel.layer.masksToBounds = true
        priorityView.layer.cornerRadius = priorityView.frame.width/2
    }
	
	override func prepareForReuse() {
		dateLabel.text = ""
		dateLabel.textColor = normalDateColor
        dateLabel.font = normalDateFont
        dateLabel.backgroundColor = normalDateBackgroundColor
        priorityView.backgroundColor = .white
	}
	
    func setCell(date: Date, todo: Todo?) {
        self.date = date
        dateLabel.text = "\(date.get(component: .day))"
        if date.isWeekend() {
			dateLabel.textColor = weekendDateColor
		}
        if date.isToday() {
            dateLabel.textColor = currentDateColor
            dateLabel.font = currentDateFont
            dateLabel.backgroundColor = currentDateBackgroundColor
        }
        
        //Marking Todos Dates
        priorityView.backgroundColor = todo?.priority.getColor() ?? .white
	}
}
