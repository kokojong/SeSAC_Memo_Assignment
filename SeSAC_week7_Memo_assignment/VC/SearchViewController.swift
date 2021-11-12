//
//  SearchViewController.swift
//  SeSAC_week7_Memo_assignment
//
//  Created by kokojong on 2021/11/10.
//

import UIKit
import SwiftUI
import RealmSwift

class SearchViewController: UIViewController {
    
    static let identifer = "SearchViewController"

    @IBOutlet weak var tableView1: UITableView!
    
    @IBOutlet weak var testLabel: UILabel!
    //    var searchedMemos: Results<Memo>!
//
    var tasks: Results<Memo>!
    
    var searchedMemos: Results<Memo>!
    
//    var searchedMemos = Results<Memo>.objects(Memo.self)
//
    var localRealm = try! Realm()
    
    var searchText = "" {
        didSet {
            print("searchText:",searchText)
            testLabel.text = searchText
//            print(UISearchController().searchBar.text)
//            print(searchBar.text!)
            print(searchController.searchBar.text)
            tableView1.reloadData()
        }
    }
    
//    var searchBarText = uivie
    
//    var searchedMemos:
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SearchViewController")
        
        tableView1.delegate = self
        tableView1.dataSource = self
        
        let nibName = UINib(nibName: HomeTableViewCell.identifier, bundle: nil)
        tableView1.register(nibName, forCellReuseIdentifier: HomeTableViewCell.identifier)
        
        tableView1.reloadData()
        
        view.backgroundColor = .black
        tableView1.backgroundColor = .clear
        tableView1.estimatedRowHeight = 100
        tableView1.rowHeight = UITableView.automaticDimension
        
        print("Realm:",localRealm.configuration.fileURL!)
//        searchedMemos = localRealm.objects(Memo.self).filter("memoTitle == ", <#T##args: Any...##Any#>)
        
        tasks = localRealm.objects(Memo.self)
        let predicate = NSPredicate(format: "memoTitle CONTAINS %@",searchText as! CVarArg)
        print("searchText: ",searchText)
        searchedMemos = tasks.filter(predicate)
        print("searchedMemos: ",searchedMemos)
       
        searchController = UISearchController()
        print(searchController.searchBar.text)
        
        tableView1.reloadData()

        
    }
    

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
//        let row = indexPath.row
//        cell.titleLabel.text = searchedMemos[indexPath.row].memoTitle
//        cell.contentLabel.text = searchedMemos[row].memoContent
        
//        let row = searchedMemos![indexPath.row]
        cell.titleLabel.text = "제목"
        cell.contentLabel.text = "내용"
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

