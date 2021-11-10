//
//  EditViewController.swift
//  SeSAC_week7_Memo_assignment
//
//  Created by kokojong on 2021/11/09.
//

import UIKit
import RealmSwift

class EditViewController: UIViewController {
    
    static let identifier = "EditViewController"
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    @IBOutlet weak var confirmBarButton: UIBarButtonItem!
    @IBOutlet weak var memoTextView: UITextView!
    
//    var isTitle = true
    var memoTitle = ""
    var memoContent = ""
    
    let localRealm = try! Realm()
    
    var passedMemo: Memo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareBarButton.tintColor = .systemOrange
        shareBarButton.title = ""

        confirmBarButton.tintColor = .systemOrange
        confirmBarButton.title = "완료"
       
        if let memo = passedMemo {
            memoTextView.text = "\(passedMemo!.memoTitle)\n\(passedMemo!.memoContent)"
        } else {
            memoTextView.text = ""
        }
        
        
        memoTextView.becomeFirstResponder()
        memoTextView.delegate = self
        
//        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "fas", style: .plain, target: self, action: nil)]
        
    }
    
    @objc func onBackBarItemClicked(){
        print("onBackBarItemClicked")
    }
    
    @IBAction func onShareBarButtonClicked(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func onConfirmBarButtonClicked(_ sender: UIBarButtonItem) {
        
        let splitTextList2 = memoTextView.text.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
        
//        아예 비어있거나, content가 없는 경우에 대한 분기처리
        if memoTextView.text.isEmpty { // 아무것도 안쓴 경우 -> 삭제
            navigationController?.popViewController(animated: true)
            return
            
        } else if splitTextList2.count == 1 { // 제목만 있는 경우
            memoTitle = String(splitTextList2[0])
            
        } else { // 내용만 있는 경우 / 내용,제목이 모두 있는 경우
            memoTitle = String(splitTextList2[0])
            memoContent = String(splitTextList2[1])
        }
        
        if passedMemo == nil { // 새롭게 작성
            let task = Memo(memoTitle: memoTitle, memoContent: memoContent, memoDate: Date())
            
            try! localRealm.write {
                localRealm.add(task)
            }
        } else { // 수정
            let task = passedMemo
            
            try! localRealm.write {
                task?.memoTitle = memoTitle
                task?.memoContent = memoContent
            }
        }
        
        navigationController?.popViewController(animated: true)
        
    }
}

extension EditViewController: UITextViewDelegate {
    
    
}
