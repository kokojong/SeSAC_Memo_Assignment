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
       
        if passedMemo != nil {
            memoTextView.text = "\(passedMemo!.memoTitle)\n\(passedMemo!.memoContent)"
            confirmBarButton.title = "완료"
        } else {
            memoTextView.text = ""
            confirmBarButton.title = "저장"
        }
        
        memoTextView.becomeFirstResponder()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if memoTextView.text == "" { // 바로 삭제
            
        } else {
            saveMemo()
            navigationController?.popViewController(animated: true)
        }
    }
    
  
    
    @IBAction func onShareBarButtonClicked(_ sender: UIBarButtonItem) {
     
        if passedMemo == nil { // 작성화면이면
            
            if memoTextView.text == "" { // 빈메모
                
                let alert = UIAlertController(title: "빈 메모", message: "빈 메모는 저장 할 수 없습니다.\n메모에 내용을 적어주세요", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "확인", style: .default)
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
                
            } else {
            
                let alert = UIAlertController(title: "저장 및 공유하기", message: "현재 메모를 저장하고 공유하시겠습니까?", preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "공유", style: .default){ _ in
                    self.saveMemo()
                    self.saveTextFile()
                    self.presentActivityViewController()
                }
                let cancel = UIAlertAction(title: "취소", style: .cancel)
                
                alert.addAction(ok)
                alert.addAction(cancel)
               
                present(alert, animated: true, completion: nil)
            
            }
            
            
            
        } else { // 수정화면이라면
            saveTextFile()
            presentActivityViewController()
            
        }
        
    }
    
    @IBAction func onConfirmBarButtonClicked(_ sender: UIBarButtonItem) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    func saveMemo() {
        
        let splitedTextList = memoTextView.text.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)
        
//        아예 비어있거나, content가 없는 경우에 대한 분기처리
        if memoTextView.text.isEmpty { // 아무것도 안쓴 경우 -> 삭제
            navigationController?.popViewController(animated: true)
            return
            
        } else if splitedTextList.count == 1 { // 제목만 있는 경우
            memoTitle = String(splitedTextList[0])
            
        } else { // 내용만 있는 경우 / 내용,제목이 모두 있는 경우
            memoTitle = String(splitedTextList[0])
            memoContent = String(splitedTextList[1])
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
        
        
    }
    
    
    func saveTextFile() {
        if passedMemo != nil {
            
            let title: String? = passedMemo!.memoTitle
            let content: String? = passedMemo!.memoContent
            let str =  "\(title!)\n\(content!)"
      
            let filename = getDocumentsDirectory().appendingPathComponent("text.txt")

            do {
                try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("알 수 없는 오류가 발생했습니다")
            }
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getDocumentDirectoryPath() -> String? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        print(path)
        
        if let directoryPath = path.first {
            return directoryPath
        } else {
            return nil
        }
        
    }
    
    
    
    func presentActivityViewController() {
        
        // 압축파일의 경로 가지고 오기
        let fileName = (getDocumentDirectoryPath()! as NSString).appendingPathComponent("text.txt")
        let fileURL = URL(fileURLWithPath: fileName)

        let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])
        
        self.present(vc, animated: true, completion: nil)
    
    }
}

