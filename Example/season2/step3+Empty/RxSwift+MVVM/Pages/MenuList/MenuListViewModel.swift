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
        // 더미 데이터
//        let menus: [Menu] = [
//            Menu(id: 0, name: "튀김1", price: 100, count: 0),
//            Menu(id: 1, name: "튀김2", price: 100, count: 0),
//            Menu(id: 2, name: "튀김3", price: 100, count: 0)
//        ]
        
        _ = APIService.fetchAllMenusRx()
            .map { data -> [MenuItem] in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                let response = try! JSONDecoder().decode(Response.self, from: data)
                
                return response.menus
            }
            .map { menuItems -> [Menu] in
                var menus: [Menu] = []
                menuItems.enumerated().forEach { (index, item) in
                    let menu = Menu.fromMenuItems(id: index, item: item)
                    menus.append(menu)
                }
                return menus
            }
            .take(1)
            .bind(to: menuObservable)
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
    
    func clearAllItemSelections() {
        _ = menuObservable
            .map { menus in
                menus.map {
                    Menu(id: $0.id, name: $0.name, price: $0.price, count: 0)
                }
            }
            .take(1) // 1번만 실행하도록 선언
            .subscribe(onNext: {
                self.menuObservable.onNext($0)
            })
    }
    
    func changeCount(item: Menu, increase: Int) {
        _ = menuObservable
            .map { menus in
                menus.map { m in
                    if m.id == item.id {
                        return Menu(id: m.id, name: m.name, price: m.price, count: max(m.count + increase, 0))
                    } else {
                        return m
                    }
                }
            }
            .take(1) // 1번만 실행하도록 선언
            .subscribe(onNext: {
                self.menuObservable.onNext($0)
            })
    }
}
