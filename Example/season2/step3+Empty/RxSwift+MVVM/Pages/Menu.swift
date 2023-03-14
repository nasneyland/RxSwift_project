//
//  Menu.swift
//  RxSwift+MVVM
//
//  Created by najin on 2023/03/13.
//  Copyright © 2023 iamchiwon. All rights reserved.
//

import Foundation

// ViewModel - 뷰를 위한 모델
struct Menu {
    var id: Int
    var name: String
    var price: Int
    var count: Int
}

extension Menu {
    static func fromMenuItems(id: Int, item: MenuItem) -> Menu {
        return Menu(id: id, name: item.name, price: item.price, count: 0)
    }
}
