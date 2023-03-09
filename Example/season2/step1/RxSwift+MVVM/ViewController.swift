//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var disposable = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //뷰 로드 시 타이머 실행 (escaping closure)
        // scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (Timer) -> Void) -> Timer
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        
        //뷰에 애니메이션 구현
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    // MARK: 방법 1 - escaping closure
    
//    // 비동기 구간에서 리턴해줄 수 없으니 클로저로 전달하기
//    // @escaping 은 지연실행을 감지하기 위해 사용한다. 본체함수가 끝나고 나서도 실행한다는 의미
//    // 또는 ((String?) -> Void) 으로 선언한다. 이렇게하면 escape가 디폴트라 선언 안해줘도 됨 -> completion?(json)
//    func downloadJson(_ url:String, _ completion: @escaping (String?) -> Void) {
//        DispatchQueue.global().async {
//            let url = URL(string: url)!
//            let data = try! Data(contentsOf: url)
//            let json = String(data: data, encoding: .utf8)
////            return json
//            DispatchQueue.main.async {
//                completion(json)
//            }
//        }
//    }
//
//    @IBAction func onLoad() {
//        editView.text = ""
//        setVisibleWithAnimation(activityIndicator, true)
//
//
//        self.downloadJson(MEMBER_LIST_URL) { json in
//            self.editView.text = json
//            self.setVisibleWithAnimation(self.activityIndicator, false)
//        }
//    }
    
    // MARK: 방법 2 - Observable
    
    // Observable = 나중에생기는데이터
    // 나중에 데이터가 생기면 리턴값을 넘겨준다.
    func downloadJson(_ url:String) -> Observable<String?> {
        return Observable.create() { f in
            DispatchQueue.global().async {
                let url = URL(string: url)!
                let data = try! Data(contentsOf: url)
                let json = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    f.onNext(json)
                }
            }
            
            return Disposables.create()
        }
    }

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)

        // subscribe 코드는 Observable에 값이 할당되면 실행되는 코드이다.
        downloadJson(MEMBER_LIST_URL)
            .subscribe { event in
                switch event {
                case .next(let json) :
                    print(json)
//                    self.editView.text = json
//                    self.setVisibleWithAnimation(self.activityIndicator, false)
                case .completed:
                    break
                case .error(_):
                    break
            }
        }
            .disposed(by: disposable)
        
        // 번외 : 해당 코드를 강제로 중지시키는 방법
//        let disposable = downloadJson(MEMBER_LIST_URL)
//            .subscribe {}
////        disposable.dispose()
//        self.disposable.insert(disposable)
        
        // 번외 : 순환참조 문제를 해결하는 방법
        // 1. 클로저에 [weak self] 로 event 선언 -> self?
        // 2. f.onNext 선언 후 f.completed로 클로저 닫아주기
        
        
        simpleObservable("najin")
//            .subscribe { event in
//                switch event {
//                case .next(let result):
//                    print(result)
//                case .completed:
//                    break
//                case .error:
//                    break
//                }
//            }
            .observeOn(MainScheduler.instance) // 쓰레드를 바꾸는 operator
            // 출력 축약형 (셋 중 원하는 클로저만 진행)
            .subscribe(onNext: {print($0)},
                       onError: {print($0)},
                       onCompleted: {print("complete")})
        
        // Observable 데이터를 리턴받을 때 쓸 수 있는 operater 이 많이 있다. (map, filter 등등 엄청 많음)
        let jsonObservable = downloadJson(MEMBER_LIST_URL)
        let helloObservable = Observable.just("hello")
        Observable.zip(jsonObservable, helloObservable) {$1 + "\n" + $0!}
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { json in
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            })
    }
    
    // Observable의 생명주기
    // 1.Create -> 2.Subscribe -> 3.onNext -> 4.onCompleted/onError -> 5.Disposed
    func simpleObservable(_ name: String) -> Observable<String?> {
        return Observable.create() { obs in
            obs.onNext("Hello")
            obs.onNext("Im \(name)")
            obs.onCompleted() // 클로저 닫기

            return Disposables.create()
        }
        
        // 위 코드의 축약형 리턴 (just) - 하나만 전달할 때
        return Observable.just("Hello Im \(name)")
        // 위 코드의 축약형 리턴 (from) - 여러개 전달할 때
        return Observable.from(["Hello","Im \(name)"])
    }
}

// MARK: RxSwift 내부 구조

// RxSwift는 비동기로 발생되는 데이터를 클로저를 통하지 않고 리턴값으로 관리하기 위해 만들어진 유틸리티 이다.

// 나중에생기는데이터 = Observable
// 나중에오면 = subscribe
// T는 제네릭 변수이다. 특정 타입을 지정하지 않고, 오는 변수의 타입을 따르는 것, 사용할 때 타입을 지정한다.

//class 나중에생기는데이터<T> {
//    private let task: (@escaping (T) -> Void) -> Void
//
//    init(task: @escaping (@escaping (T) -> Void) -> Void) {
//        self.task = task
//    }
//
//    func 나중에오면(_ f: @escaping (T) -> Void) {
//        task(f)
//    }
//}
