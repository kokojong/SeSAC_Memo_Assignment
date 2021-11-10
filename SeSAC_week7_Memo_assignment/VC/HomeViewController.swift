//
//  HomeViewController.swift
//  SeSAC_week7_Memo_assignment
//
//  Created by kokojong on 2021/11/08.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController {

//    @IBOutlet weak var memoCountLabel: UILabel!
//    @IBOutlet weak var memoSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var editToolbar: UIToolbar!
    @IBOutlet weak var editToolbarButton: UIBarButtonItem!
    
    var memoCount = 1000
    
    var tasks: Results<Memo>!
    
    var pinnedMemos: Results<Memo>!
    
    var unPinnedMemos: Results<Memo>!
    
    let localRealm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIsFirstLaunch()
        
        /* --------- Realm ---------- */
        
        print("Realm:",localRealm.configuration.fileURL!)
        tasks = localRealm.objects(Memo.self)
        pinnedMemos = localRealm.objects(Memo.self).filter("isPinned == true").sorted(byKeyPath: "memoDate", ascending: false) // pin된거,
        unPinnedMemos = localRealm.objects(Memo.self).filter("isPinned == false").sorted(byKeyPath: "memoDate", ascending: false)
        
        // NumberFormatter()
        memoCount = pinnedMemos.count + unPinnedMemos.count
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(for: memoCount)!
        
        
        /* ----------- UI Setting ----------- */
        // light 모드일때도 보이게
        view.backgroundColor = .black
        
        // UISearchController()
        let searchViewController = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: SearchViewController.identifer) as? SearchViewController
            // This view controller is interested in table view row selections.
//        searchViewController!..delegate = self
        let searchController = UISearchController(searchResultsController: searchViewController)
        searchController.searchBar.placeholder = "검색"
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        searchController.searchBar.tintColor = .systemOrange
        searchController.hidesNavigationBarDuringPresentation = true // 스크롤 할 때 타이틀 숨기기 -> 왜 안되는걸꽈
        
        navigationItem.searchController = searchController
        navigationItem.title = "\(formattedNumber)개의 메모"
        self.navigationController?.navigationBar.prefersLargeTitles = true // Large title 사용하기
        self.navigationItem.hidesSearchBarWhenScrolling = false // 스크롤 할 때 서치부분은 남겨두기
        
        tableView.backgroundColor = .clear
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nibName = UINib(nibName: HomeTableViewCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: HomeTableViewCell.identifier)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        editToolbarButton.setBackgroundImage(UIImage(systemName: "square.and.pencil"), for: .normal, style: .plain, barMetrics: .default)
        editToolbarButton.tintColor = UIColor.systemOrange
           
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    
    @IBAction func onEditToolbarButtonClicked(_ sender: UIBarButtonItem) {
        print("onEditToolbarButtonClicked")
        
        let sb = UIStoryboard(name: "Edit", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: EditViewController.identifier) as! EditViewController

        let backBarItem = UIBarButtonItem(title: "메모", style: .plain , target: self, action: nil) // action은 nil

        self.navigationItem.backBarButtonItem = backBarItem
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func checkIsFirstLaunch() {
        if UserDefaults.standard.bool(forKey: "first launch") != true {
            UserDefaults.standard.set(true, forKey: "first launch")
            print("first")
            presentPopup()
        } else{ // 임시 -> 처음이 아님 -> 나중에 지워주기
            presentPopup()
        }
        
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
        
        return section == 0 ? pinnedMemos.count : unPinnedMemos.count
//        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
      
        if indexPath.section == 0 {
            let row = pinnedMemos[indexPath.row]
            cell.titleLabel.text = row.memoTitle
            cell.contentLabel.text = "\(row.memoDate)  \(row.memoContent)"
            
        }
        else if indexPath.section == 1 {
            let row = unPinnedMemos[indexPath.row]
            cell.titleLabel.text = row.memoTitle
            cell.contentLabel.text = "\(row.memoDate)  \(row.memoContent)"
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
        
        if pinnedMemos.count == 0 && section == 0 { return 0 }
        return 40 // 나머지 경우
    }
    
    // pin 액션
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 0 {
            let unpinAction = UIContextualAction(style: .normal, title: "") { action, view, completionHandler in
                completionHandler(true)
                
                let toUpdate = self.pinnedMemos[indexPath.row]
                try! self.localRealm.write {
                    toUpdate.isPinned = false
                }
                self.tableView.reloadData()
                
            }
            unpinAction.backgroundColor = .systemOrange
            unpinAction.image = UIImage(systemName: "pin.slash.fill")
            
            return UISwipeActionsConfiguration(actions: [unpinAction])
            
        } else {
            let pinAction = UIContextualAction(style: .normal, title: "", handler: { action, view, completionHandler in
                completionHandler(true)
               
                if self.pinnedMemos.count < 5 { // 5개 미만일 때
                    let toUpdate = self.unPinnedMemos[indexPath.row]
                    try! self.localRealm.write {
                        toUpdate.isPinned = true
                    }
                    self.tableView.reloadData()
                    
                } else { // 고정된 메모가 5개 이상일 때(더이상 불가
                    
                    let alert = UIAlertController(title: "고정된 메모가 너무 많습니다", message: "메모는 5개까지만 고정할 수 있습니다.\n월 1990원으로 무제한으로 즐겨보세요 :)", preferredStyle: .alert)
                    // 2. UIAlertAction 생성 : 버튼들을 만들어준다
                    let ok = UIAlertAction(title: "확인", style: .default)
                    
                    // 3. 1과 2를 합쳐준다
                    // addAction의 순서대로 버튼이 붙는다
                    alert.addAction(ok)
                    
                    // 4. Present (보여줌) - modal처럼
                    self.present(alert, animated: true, completion: nil)
                }
                
                
            })
            
            pinAction.backgroundColor = .systemOrange
            pinAction.image = UIImage(systemName: "pin.fill")
            
            return UISwipeActionsConfiguration(actions: [pinAction])
        }
        
    }
    
    // delete 액션
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 0 {
            let deleteAction = UIContextualAction(style: .destructive, title: "", handler: { action, view, completionHandler in
                completionHandler(true)
                
                let toDelete = self.pinnedMemos[indexPath.row]
                try! self.localRealm.write {
                    self.localRealm.delete(toDelete)
                }
                self.tableView.reloadData()
                
            })
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            return UISwipeActionsConfiguration(actions: [deleteAction])
        } else {
            let deleteAction = UIContextualAction(style: .destructive, title: "", handler: { action, view, completionHandler in
                completionHandler(true)
                
                let toDelete = self.unPinnedMemos[indexPath.row]
                try! self.localRealm.write {
                    self.localRealm.delete(toDelete)
                }
                self.tableView.reloadData()
            })
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sb = UIStoryboard(name: "Edit", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: EditViewController.identifier) as! EditViewController
        
        let backBarItem = UIBarButtonItem(title: "검색", style: .plain , target: self, action: nil)
        
        if indexPath.section == 0 {
            vc.passedMemo = pinnedMemos[indexPath.row]
        } else {
            vc.passedMemo = unPinnedMemos[indexPath.row]
        }

        self.navigationItem.backBarButtonItem = backBarItem
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
