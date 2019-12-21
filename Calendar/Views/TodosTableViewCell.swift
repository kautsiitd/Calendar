//
//  TodosTableViewCell.swift
//  Calendar
//
//  Created by Kautsya Kanu on 21/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit

class TodosTableViewCell: UITableViewCell {
    //MARK: Elements
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    
    override func prepareForReuse() {
        dateLabel.text = ""
        titleLabel.text = ""
        contentLabel.text = ""
    }
    
    func setCell(todo: Todo) {
        dateLabel.text = todo.date.uniqueId()
        titleLabel.text = todo.title
        contentLabel.text = todo.comments
    }
}
