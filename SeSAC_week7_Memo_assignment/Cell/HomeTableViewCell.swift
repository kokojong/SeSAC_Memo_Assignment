//
//  HomeTableViewCell.swift
//  SeSAC_week7_Memo_assignment
//
//  Created by kokojong on 2021/11/08.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    static let identifier = "HomeTableViewCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.backgroundColor = .black
        titleLabel.textColor = .black
        contentLabel.textColor = .black
        titleLabel.font = .boldSystemFont(ofSize: 15)
        contentLabel.font = .systemFont(ofSize: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
