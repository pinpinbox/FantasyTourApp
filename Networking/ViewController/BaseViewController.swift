//
//  AppBaseViewController.swift
//  Networking
//
//  Created by Antelis on 2019/4/3.
//  Copyright © 2019 . All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa



@objc protocol DrawerVCProtocol {
    func switchDrawer()
}

class BaseViewController: UIViewController {
    
    @IBOutlet var drawerVC: DrawerVCProtocol?
    
    @IBOutlet weak var optionBar : UITabBar?
    var pageVC : UIPageViewController?
    var viewModel = BaseViewModel()
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let s = segue.identifier, s == "pagevcs" {
            self.pageVC = segue.destination as? UIPageViewController
            if let p = self.pageVC {
                if let st = self.storyboard {
                    self.viewModel.prepareListVC(st)
                }
                p.dataSource = self.viewModel
                p.delegate = self.viewModel
                
            }
        }
    }
    
    private func bind() {
        if let bar = self.optionBar {
            bar.delegate = self.viewModel
            bar.selectedItem = bar.items?.first
        }
        
        if let p = self.pageVC {
            self.viewModel.curList
                .asObservable()
                .subscribe { (index) in
                    
                    if let i = index.element, let bar = self.optionBar {
                        bar.selectedItem = bar.items?[i]
                        if let v = p.viewControllers?.first, let tv = v as? TourListViewController {
                            let list = self.viewModel.listVCs[i]
                            
                            if list.viewModel.listType.indexOf() > tv.viewModel.listType.indexOf() {
                                p.setViewControllers([list], direction: .forward, animated: true, completion: nil)
                            } else {
                                p.setViewControllers([list], direction: .reverse, animated: true, completion: nil)
                            }
                        } else {
                            p.setViewControllers([self.viewModel.listVCs[i]], direction: .forward, animated: true, completion: nil)
                        }
                        
                        
                    }
                }.disposed(by : disposeBag)
        }
    }
    
    @IBAction func drawerSwitchDidPressed(_ sender: Any?) {
        if let d = self.drawerVC {
            d.switchDrawer()
        }
    }
    
    
}
