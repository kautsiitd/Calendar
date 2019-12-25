//
//  CalendarMonthHeaderView.swift
//  Calendar
//
//  Created by Kautsya Kanu on 25/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit

class CalendarMonthHeaderView: UICollectionReusableView {
    
    //MARK: Elements
    @IBOutlet private weak var monthYearLabel: UILabel!
    
    override func prepareForReuse() {
        monthYearLabel.text = ""
    }
    
    func setView(date: Date) {
        monthYearLabel.text = date.convertTo(string: "MMM YYYY")
    }
}
