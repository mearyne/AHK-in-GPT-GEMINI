# AHK-in-GPT-GEMINI

<img width="432" alt="image" src="https://github.com/user-attachments/assets/a2719ecd-9016-4e73-81d3-ecc0f52b4c77" />

# 🚀 Dual Search Helper (for Microsoft Edge)

**Dual Search Helper**는 한 번의 입력으로 **Gemini**와 **ChatGPT**에서 동시에 해답을 찾을 수 있도록 돕는 AutoHotkey 기반의 생산성 도구입니다. 브라우저 탭을 지능적으로 관리하여 중복 탭 생성을 방지하고, 과거 검색 기록을 효율적으로 관리할 수 있습니다.

## ✨ 주요 기능

* **Dual Search**: 체크박스 선택에 따라 Gemini와 ChatGPT에 검색어를 동시 전달합니다.
* **Smart Tab Recycling**:
* 이미 열려 있는 서비스 탭이 있다면 새 탭을 열지 않고 해당 탭에서 검색을 이어갑니다.
* 탭 제목뿐만 아니라 **주소창(URL) 감지** 로직을 통해 정확하게 대상 탭을 찾아냅니다.
* 브라우저가 꺼진 상태에서 실행 시 탐색 과정을 생략하고 즉시 검색을 시작합니다.


* **History Management**:
* 검색 기록 자동 저장 (`history.txt`).
* 중요한 프롬프트 **즐겨찾기(★)** 기능.
* 검색 기록 **다중 선택 및 일괄 삭제** 지원.


* **User-Friendly UI/UX**:
* `F1`: GUI 창 호출 및 활성화.
* `Enter`: 프롬프트 입력창 내 줄바꿈.
* `Shift + Enter`: 즉시 검색 실행.
* `NEW` 체크박스: 필요 시 기존 탭을 무시하고 무조건 새 탭에서 검색.



## 🛠 설치 및 요구 사항

* **OS**: Windows 10/11
* **Language**: [AutoHotkey](https://www.autohotkey.com/) v1.1 이상
* **Browser**: Microsoft Edge (기본 경로 설치 권장)

## 📖 사용 방법

1. `DualSearchHelper.ahk` 스크립트를 실행합니다. (관리자 권한이 자동으로 요청됩니다.)
2. `F1` 키를 눌러 GUI를 엽니다.
3. 상단 입력창에 프롬프트를 작성합니다. (줄바꿈은 `Enter`)
4. `Shift + Enter` 또는 `Dual Search` 버튼을 눌러 검색을 실행합니다.
5. 하단 리스트뷰에서 과거 기록을 더블클릭하여 재검색하거나, 즐겨찾기를 관리합니다.

## 📂 파일 구조

* `DualSearchHelper.ahk`: 메인 스크립트 파일
* `history.txt`: 검색 기록 및 즐겨찾기 데이터 저장 파일 (자동 생성)

## ⚠️ 참고 사항

* **인식 성능**: 웹페이지 로딩 속도에 따라 검색어가 주소창에 입력되는 것을 방지하기 위해 최적화된 `Sleep` 타임이 적용되어 있습니다. PC 환경에 따라 스크립트 내 `Sleep` 수치를 조정할 수 있습니다.
* **탭 탐색**: 기존 탭 탐색은 최대 5회 순회하며, 일치하는 탭이 없을 경우 자동으로 새 탭을 생성합니다.

---
```

GitHub 저장소 생성이나 커밋 과정에서 도움이 필요하시면 말씀해 주세요! ☺️
