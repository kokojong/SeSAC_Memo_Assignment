//
//  HomeViewController.swift
//  SeSAC_week7_Memo_assignment
//
//  Created by kokojong on 2021/11/08.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var memoCountLabel: UILabel!
    @IBOutlet weak var memoSearchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var editToolbarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.bool(forKey: "first launch") != true {
            
            UserDefaults.standard.set(true, forKey: "first launch")
            print("first")
            // popup
            presentPopup()
            
        } else{ // 임시
            presentPopup()
        }
        
        view.backgroundColor = .black
        
        memoCountLabel.text = "100개의 메모"
        memoCountLabel.font = .boldSystemFont(ofSize: 30)
        tableview.backgroundColor = .clear
        
        tableview.delegate = self
        tableview.dataSource = self
        let nibName = UINib(nibName: HomeTableViewCell.identifier, bundle: nil)
        tableview.register(nibName, forCellReuseIdentifier: HomeTableViewCell.identifier)
        
        tableview.estimatedRowHeight = 100
        tableview.rowHeight = UITableView.automaticDimension
           
        
    }
    @IBAction func onEditToolbarButtonClicked(_ sender: UIBarButtonItem) {
        print("onEditToolbarButtonClicked")
    }
    
    func presentPopup() {
        let sb = UIStoryboard(name: "Popup", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: PopupViewController.identifier)
        
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "고정된 메모" : "메모"
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
    
    // pin 액션
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pinAction = UIContextualAction(style: .normal, title: "", handler: { action, view, completionHandler in
            
            completionHandler(true)
        })
        pinAction.backgroundColor = .systemOrange
        // 현재 핀상태 여부 분기처리 추가하기
        pinAction.image = UIImage(systemName: "pin.fill")
        
        return UISwipeActionsConfiguration(actions: [pinAction])
    }
    
    // delete 액션
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "", handler: { action, view, completionHandler in
            completionHandler(true)
        })
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    }
    
 
    
    
    
    
    
    
}
