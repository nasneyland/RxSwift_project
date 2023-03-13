//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MenuViewController: UIViewController {
    
    // 뷰에서 필요한 모델 ViewModel 에서 가져오기
    let viewModel = MenuListViewModel()
    
    // Observe 모델 종료 모델
    var disposeBag = DisposeBag()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // table뷰의 딜리게이트 없이 rx로 사용하는 방법
        viewModel.menuObservable
            .bind(to: tableView.rx.items(cellIdentifier: "MenuItemTableViewCell", cellType: MenuItemTableViewCell.self)) { index, menu, cell in
                cell.title.text = menu.name
                cell.price.text = "\(menu.price)"
                cell.count.text = "\(menu.count)"
            }
            .disposed(by: disposeBag)
        
        viewModel.totalPrice
            .map { $0.currencyKR() } // 요소 통화포맷으로 변경
            .observeOn(MainScheduler.instance) //UI 작업 메인스레드에서 관리
            .bind(to: totalPrice.rx.text) // UI 요소에 값 전달, 순환참조 문제도 알아서 해결해줌
            .disposed(by: disposeBag) // 종료 선언
        
        viewModel.itemsCount
//            .scan(0, accumulator: +) // reduce 같은 역할
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                self.itemCountLabel.text = "\($0)" // 값 변경이 감지되면 UI 업데이트
            }) // bind로 간단하게 나타낼 수 있음
            //.bind(to: itemCountLabel.rx.text)
            .disposed(by: disposeBag) // 종료 선언
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
            let orderVC = segue.destination as? OrderViewController {
            // TODO: pass selected menus
        }
    }

    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }

    // MARK: - InterfaceBuilder Links

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!

    @IBAction func onClear() {
    }

    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
//        performSegue(withIdentifier: "OrderViewController", sender: nil)
//        viewModel.totalPrice.onNext(100)
    }
}   

//extension MenuViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.itemsCount
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell") as! MenuItemTableViewCell
//
//        let menu = viewModel.menus[indexPath.row]
//        cell.title.text = menu.name
//        cell.price.text = "\(menu.price)"
//        cell.count.text = "\(menu.count)"
//
//        return cell
//    }
//}
