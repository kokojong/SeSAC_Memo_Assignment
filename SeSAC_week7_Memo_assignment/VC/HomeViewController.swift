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
    
    var memoCount = 1000 // numberFormatter test
    
    var tasks: Results<Memo>!
    
    var pinnedMemos: Results<Memo>!{
        didSet {
            tableView.reloadData()
        }
    }
    
    var unPinnedMemos: Results<Memo>! {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchedMemos: Results<Memo>! {
        didSet {
            tableView.reloadData()
        }
    }
    
    let localRealm = try! Realm()
    
    var searchViewController: SearchViewController!
    
    var searchController:  UISearchController!
    
    
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
       
        // UISearchController()
        
//        searchViewController = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: SearchViewController.identifer) as? SearchViewController
        // nil로 바꾸면서 일단 주석처리
        
            // This view controller is interested in table view row selections.
//        searchViewController!.tableView.delegate = self
        
//        searchController = UISearchController(searchResultsController: searchViewController) ->
        searchController = UISearchController(searchResultsController: nil)
        
        let predicate = NSPredicate(format: "memoTitle CONTAINS[c] %@ OR memoContent CONTAINS[c]  %@",searchController.searchBar.text as! CVarArg,searchController.searchBar.text as! CVarArg)
        print(searchController.searchBar.text!)
        searchedMemos = localRealm.objects(Memo.self).filter(predicate).sorted(byKeyPath: "memoDate", ascending: false)
        print(searchedMemos)
        
        
        searchController.searchBar.placeholder = "검색"
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        searchController.searchBar.tintColor = .systemOrange
        // 다크모드 아닐때도 검색 text 흰색 하려고 했는데 실패..
//        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        searchController.hidesNavigationBarDuringPresentation = true // 스크롤 할 때 타이틀 숨기기 -> 왜 안되는걸꽈
        
//        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchResultsUpdater = self
        
        navigationItem.searchController = searchController
        navigationItem.title = "\(formattedNumber)개의 메모"
        self.navigationController?.navigationBar.prefersLargeTitles = true // Large title 사용하기
        self.navigationItem.hidesSearchBarWhenScrolling = false // 스크롤 할 때 서치부분은 남겨두기
        
        
        
        // light 모드일때도 보이게
        view.backgroundColor = .black
        
        
        /* -------------------- */
        
        tableView.backgroundColor = .clear
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nibName = UINib(nibName: HomeTableViewCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: HomeTableViewCell.identifier)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        editToolbarButton.setBackgroundImage(UIImage(systemName: "square.and.pencil"), for: .normal, style: .plain, barMetrics: .default)
        editToolbarButton.tintColor = UIColor.systemOrange
           
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        memoCount = pinnedMemos.count + unPinnedMemos.count
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(for: memoCount)!
        navigationItem.title = "\(formattedNumber)개의 메모"
        self.navigationController?.navigationBar.prefersLargeTitles = true
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
//            presentPopup()
        }
        
    }

    func presentPopup() {
        let sb = UIStoryboard(name: "Popup", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: PopupViewController.identifier)
        
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    func searchBarIsEmpty() -> Bool {
      // Returns true if the text is empty or nil
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
      return searchController.isActive && !searchBarIsEmpty()
    }
    
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering() {
            return searchedMemos.count
            
        } else {
            return section == 0 ? pinnedMemos.count : unPinnedMemos.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        cell.titleLabel.textColor = .white
        cell.contentLabel.textColor = .lightGray
        
        let nowDate = Calendar.current.dateComponents([.weekOfYear, .day], from: Date())
        
        if isFiltering() {
            let row = searchedMemos[indexPath.row]
            cell.titleLabel.text = row.memoTitle
           
            
            let date = row.memoDate // 작성시간
            let releasedDate = Calendar.current.dateComponents([.weekOfYear, .day], from: date)
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.locale = Locale(identifier: "ko_kr")
            
            if releasedDate.day == nowDate.day {
                dateFormatter.dateFormat = "a hh:mm"
            } else if releasedDate.weekOfYear == nowDate.weekOfYear {
                dateFormatter.dateFormat = "EEEE"
            } else {
                dateFormatter.dateFormat = "yyyy.MM.dd a hh:mm" //
            }
            
            
            
            let str = dateFormatter.string(from: date) // 현재 시간의 Date를 format에 맞춰 string으로 반환
            cell.contentLabel.text = "\(str)  \(row.memoContent)"
            
            // 타이틀
//            let attributedTitleString = NSMutableAttributedString(string: cell.titleLabel.text!)
//            attributedTitleString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: ( cell.titleLabel.text as! NSString).range(of: searchController.searchBar.text!))
//            cell.titleLabel.attributedText = attributedTitleString
            
            // 내용
//            let attributedContentString = NSMutableAttributedString(string: cell.contentLabel.text!)
//            attributedContentString.addAttribute(.foregroundColor, value: UIColor.systemOrange, range: ( cell.contentLabel.text as! NSString).range(of: searchController.searchBar.text!))
//            cell.contentLabel.attributedText = attributedContentString
            
            // 위의 방법대로 하면 일치하는 값중에 맨앞에만 색칠이 된다
            // highlight를 이용해서 
            cell.titleLabel.highlight(searchText: searchController.searchBar.text!)
            cell.contentLabel.highlight(searchText: searchController.searchBar.text!)
            
            
            
        } else {
            if indexPath.section == 0 {
                let row = pinnedMemos[indexPath.row]
                cell.titleLabel.text = row.memoTitle
                
                let date = row.memoDate // 작성시간
                let releasedDate = Calendar.current.dateComponents([.weekOfYear, .day], from: date)
                
                let dateFormatter = DateFormatter()
                
                dateFormatter.locale = Locale(identifier: "ko_kr")
                
                if releasedDate.day == nowDate.day {
                    dateFormatter.dateFormat = "a hh:mm"
                } else if releasedDate.weekOfYear == nowDate.weekOfYear {
                    dateFormatter.dateFormat = "EEEE"
                } else {
                    dateFormatter.dateFormat = "yyyy.MM.dd a hh:mm" //
                }
                
                let str = dateFormatter.string(from: date) // 현재 시간의 Date를 format에 맞춰 string으로 반환
                cell.contentLabel.text = "\(str)  \(row.memoContent)"
                
            } else if indexPath.section == 1 {
                let row = unPinnedMemos[indexPath.row]
                cell.titleLabel.text = row.memoTitle
                
                let date = row.memoDate // 작성시간
                let releasedDate = Calendar.current.dateComponents([.weekOfYear, .day], from: date)
                
                let dateFormatter = DateFormatter()
                
                dateFormatter.locale = Locale(identifier: "ko_kr")
                
                if releasedDate.day == nowDate.day {
                    dateFormatter.dateFormat = "a hh:mm"
                } else if releasedDate.weekOfYear == nowDate.weekOfYear {
                    dateFormatter.dateFormat = "EEEE"
                } else {
                    dateFormatter.dateFormat = "yyyy.MM.dd a hh:mm" //
                }
                
                let str = dateFormatter.string(from: date) // 현재 시간의 Date를 format에 맞춰 string으로 반환
                cell.contentLabel.text = "\(str)  \(row.memoContent)"
                
            }
            
        }
      
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if isFiltering() {
            return "\(searchedMemos.count)개 검색됨"
            
        } else {
            if section == 0 {
                return "고정된 메모"
            } else {
                return "메모"
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView{
            headerView.textLabel?.textColor = .white
            headerView.textLabel?.font = .boldSystemFont(ofSize: 20)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if isFiltering() {
            return 40
            
        } else {
            if pinnedMemos.count == 0 && section == 0 { return 0 }
            return 40 // 나머지 경우
        }
        
        
    }
    
    
    // pin 액션
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if isFiltering() {
            
            if searchedMemos[indexPath.row].isPinned == true { // 고정된거 -> 고정해제
                
                let unpinAction = UIContextualAction(style: .normal, title: "") { action, view, completionHandler in
                    completionHandler(true)
                    
                    let toUpdate = self.searchedMemos[indexPath.row]
                    try! self.localRealm.write {
                        toUpdate.isPinned = false
                    }
                    self.tableView.reloadData()
                    
                }
                unpinAction.backgroundColor = .systemOrange
                unpinAction.image = UIImage(systemName: "pin.slash.fill")
                
                return UISwipeActionsConfiguration(actions: [unpinAction])
                
                
            } else { // 고정 안된거 -> 고정
                
                let pinAction = UIContextualAction(style: .normal, title: "", handler: { action, view, completionHandler in
                    completionHandler(true)
                   
                    if self.pinnedMemos.count < 5 { // 5개 미만일 때
                        let toUpdate = self.searchedMemos[indexPath.row]
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
            
            
        } else { // isFiltering X
            
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
        
    }
    
    // delete 액션
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if isFiltering() {
            
            let deleteAction = UIContextualAction(style: .destructive, title: "", handler: { action, view, completionHandler in
                completionHandler(true)
                
                // 메모 삭제시 alert
                let alert = UIAlertController(title: "메모 삭제", message: "메모가 삭제됩니다\n정말로 삭제하시겠습니까?", preferredStyle: .alert)
       
                let ok = UIAlertAction(title: "삭제", style: .cancel) { _ in
                    let toDelete = self.searchedMemos[indexPath.row]
                    try! self.localRealm.write {
                        self.localRealm.delete(toDelete)
                    }
                    self.tableView.reloadData()
                }
                let cancel = UIAlertAction(title: "취소", style: .default)
        
                alert.addAction(ok)
                alert.addAction(cancel)
               
                self.present(alert, animated: true, completion: nil)
            })
            
            deleteAction.image = UIImage(systemName: "trash.fill")
            return UISwipeActionsConfiguration(actions: [deleteAction])
            
            
        } else {
            
            if indexPath.section == 0 {
                let deleteAction = UIContextualAction(style: .destructive, title: "", handler: { action, view, completionHandler in
                    completionHandler(true)
                    
                    let alert = UIAlertController(title: "메모 삭제", message: "메모가 삭제됩니다\n정말로 삭제하시겠습니까?", preferredStyle: .alert)
           
                    let ok = UIAlertAction(title: "삭제", style: .cancel) { _ in
                        let toDelete = self.pinnedMemos[indexPath.row]
                        try! self.localRealm.write {
                            self.localRealm.delete(toDelete)
                        }
                        self.tableView.reloadData()
                    }
                    let cancel = UIAlertAction(title: "취소", style: .default)
            
                    alert.addAction(ok)
                    alert.addAction(cancel)
                   
                    self.present(alert, animated: true, completion: nil)
                    
                    
                    
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
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sb = UIStoryboard(name: "Edit", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: EditViewController.identifier) as! EditViewController
        
        let backBarItem = UIBarButtonItem(title: "검색", style: .plain , target: self, action: nil)
        
        if isFiltering() {
            vc.passedMemo = searchedMemos[indexPath.row]
            
        } else { // 검색중
            
            if indexPath.section == 0 {
                vc.passedMemo = pinnedMemos[indexPath.row]
            } else {
                vc.passedMemo = unPinnedMemos[indexPath.row]
            }
        
        
        }
        self.navigationItem.backBarButtonItem = backBarItem
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }

    // 스크롤시에 키보드 내리기
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.endEditing(true)
    }
    
}

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
        self.tableView.reloadData()
    }
    
}

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        // Apply the filtered results to the search results table.
        guard let searchText = searchController.searchBar.text else { return }
        print("resultsUpdating searchText : ",searchText)
//        self.searchText = searchController.searchBar.text ?? ""
        let predicate = NSPredicate(format: "memoTitle CONTAINS[c] %@ OR memoContent CONTAINS[c]  %@",searchController.searchBar.text as! CVarArg,searchController.searchBar.text as! CVarArg)
        searchedMemos = localRealm.objects(Memo.self).filter(predicate).sorted(byKeyPath: "memoDate", ascending: false)
        print("searchedMemos : ",searchedMemos)
        
    }
        
        
//        if let searchViewController = searchController.searchResultsController as? SearchViewController {
//
////            let predicate = NSPredicate(format: "memoTitle CONTAINS 1")
//            let predicate = NSPredicate(format: "memoTitle CONTAINS %@",searchController.searchBar.text as! CVarArg)
////
//            searchViewController.searchedMemos = tasks.filter(predicate)
//            print("searchedMemos from : ",tasks.filter(predicate))
////            print("searchViewController.searchedMemos :",searchViewController.searchedMemos!)
//
//            searchViewController.searchText = searchController.searchBar.text!
////            searchViewController.testLabel.text = searchController.searchBar.text
//            searchViewController.tableView1.reloadData()
//        }
 
    
}

//
//extension HomeViewController: UISearchControllerDelegate {
//
//    func presentSearchController(_ searchController: UISearchController) {
//        //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
//    }
//
//    func willPresentSearchController(_ searchController: UISearchController) {
//        //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
//    }
//
//    func didPresentSearchController(_ searchController: UISearchController) {
//        //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
//    }
//
//    func willDismissSearchController(_ searchController: UISearchController) {
//        //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
//    }
//
//    func didDismissSearchController(_ searchController: UISearchController) {
//        //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
//    }
//
//}

extension UILabel {
  
    func highlight(searchText: String, color: UIColor = .systemOrange) {
        guard let labelText = self.text else { return }
        do {
            let mutableString = NSMutableAttributedString(string: labelText)
            let regex = try NSRegularExpression(pattern: searchText, options: .caseInsensitive)
            
            for match in regex.matches(in: labelText, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: labelText.utf16.count)) as [NSTextCheckingResult] {
                mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: match.range)
//                mutableString.addAttribute(.foregroundColor, value: UIColor.green, range: match.range)
//                mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: <#T##Any#>, range: <#T##NSRange#>)
            }
            self.attributedText = mutableString
        } catch {
            print(error)
        }
    }
}
