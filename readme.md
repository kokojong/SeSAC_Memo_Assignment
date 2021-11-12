# SeSAC_week7_메모앱(평가과제)

## 시연 영상

| 시연 기기  | 시연 영상 |
| --- | --- |
| iPhone 13 Pro Max | ![iPhone13Max_Run](https://user-images.githubusercontent.com/61327153/141435548-a60689e9-032c-4927-9416-0d5a7bd5bd15.gif) |
| iPhone 8 | ![iPhone8_Run](https://user-images.githubusercontent.com/61327153/141439276-805c626a-a013-4608-9661-0355deee26a7.gif) |


## 최초 팝업 화면
![iPhone13Max_Launch](https://user-images.githubusercontent.com/61327153/141430951-cbac9806-07c8-490a-909a-c6ac08ff0ce9.gif)

- 앱을 처음 시작하게 되면 popup이 노출됩니다.

## 메모 리스트 화면(HomeVC)
![iPhone13Max_MemoList](https://user-images.githubusercontent.com/61327153/141436059-392f74df-6f25-4089-befd-169d255bfb01.gif)

- 작성된 메모가 최신순으로 정렬됩니다
- 메모를 고정할 수 있고 최대 5개까지 가능합니다 (추가 결제를 하면 이용하도록 해봤습니다)
- 고정된 메모도 최신순으로 정렬됩니다
- 고정된 메모가 없다면 섹션을 표시하지 않습니다
- swipe로 고정,고정해제,삭제 기능합니다
- 삭제 시에 삭제 여부를 물어봅니다
- 보이는 날짜는 오늘/이번주/이외에 따라 다릅니다

## 검색 기능(HomeVC에서 처리)
![iPhone13Max_Search](https://user-images.githubusercontent.com/61327153/141436602-21a16342-2e80-4f12-8f46-c7f500321d3b.gif)

## 작성 수정 기능(EditVC)
![iPhone13Max_Edit](https://user-images.githubusercontent.com/61327153/141437453-535270c9-3c17-404a-b123-b6d1ef3ba1c0.gif)

## 찾아낸 버그
- 테이블 뷰의 백그라운드가 검정색이라 구분이 잘 안된다(다크모드 대응을 하다가 실수했다..)
- 수정 화면에서 txt파일을 덮어쓰고 파일을 실행시켰는데 이전의 값이 들어감(두번째로 파일을 공유하게 되면 안된다)
- 첫 화면에서 간헐적으로(정확한 케이스를 찾고있따..) 메모의 갯수가 정확하게 나오지 않음(추가 삭제시 반영이 안된다)
