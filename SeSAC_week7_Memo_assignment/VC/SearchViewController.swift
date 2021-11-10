//
//  SearchViewController.swift
//  SeSAC_week7_Memo_assignment
//
//  Created by kokojong on 2021/11/10.
//

import UIKit
import SwiftUI

class SearchViewController: UIViewController {
    
    static let identifer = "SearchViewController"

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SearchViewController")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nibName = UINib(nibName: HomeTableViewCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: HomeTableViewCell.identifier)
        
        tableView.reloadData()
        
        view.backgroundColor = .black
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension

        // Do any additional setup after loading the view.
    }


}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        cell.titleLabel.text = "test1"
        cell.contentLabel.text = "test2"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView{
            headerView.textLabel?.textColor = .white
            headerView.textLabel?.font = .boldSystemFont(ofSize: 20)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "n개 찾음"
    }
    
}
