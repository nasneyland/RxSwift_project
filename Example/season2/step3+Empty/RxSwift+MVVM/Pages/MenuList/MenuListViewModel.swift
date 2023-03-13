//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by najin on 2023/03/13.
//  Copyright © 2023 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class MenuListViewModel {
    
    init() {
        let menus: [Menu] = [
            Menu(name: "튀김1", price: 100, count: 0),
            Menu(name: "튀김2", price: 100, count: 0),
            Menu(name: "튀김3", price: 100, count: 0)
        ]
        
        menuObservable.onNext(menus)
    }
    
    //totalPrice 선언 변천사
    
    //1. 일반 변수로 선언 -> 값이 변경될 때 자동으로 감지되게 할 수 없을까?
//    let totalPrice: Int = 10000
    //2. Observable로 선언 -> 선언한 값을 변경할 수가 없다.
//    let totalPrice: Observable<Int> = Observable.just(10000)
    //3. PublishSubject로 선언
//    let totalPrice: PublishSubject<Int> = PublishSubject()
    //4. price말고 model전체를 Observable 하게 만들고싶다
    // PublishSubject는 init에서 초기화하면 컨트롤러에서 변화감지를 못한다
//    var menuObservable = PublishSubject<[Menu]>()
    //5. BehaviorSubject는 호출 시 젤 마지막 데이터를 불러온다.
    var menuObservable = BehaviorSubject<[Menu]>(value: [])
    
    lazy var totalPrice = menuObservable.map {
        $0.map { $0.price * $0.count }.reduce(0,+)
    }
    lazy var itemsCount = menuObservable.map {
        $0.map { $0.count }.reduce(0,+)
    }
}
