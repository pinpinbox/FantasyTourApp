//
//  BaseVCViewModel.swift
//  Networking
//
//  Created by Antelis on 2019/4/19.
//  Copyright © 2019 Scott Gardner. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class BaseViewModel : NSObject, UIPageViewControllerDelegate, UIPageViewControllerDataSource,UITabBarDelegate {
    
    var listVCs : Array<TourListViewController> = []
    let curList = BehaviorRelay<Int>(value: 0)
    
    
    func prepareListVC(_ storyboard: UIStoryboard) {
        if let v = storyboard.instantiateViewController(withIdentifier: "TourListViewController") as? TourListViewController,
            let v1 = storyboard.instantiateViewController(withIdentifier: "TourListViewController") as? TourListViewController,
            let v2 = storyboard.instantiateViewController(withIdentifier: "TourListViewController") as? TourListViewController {
            v.viewModel.listType = .latest
            v1.viewModel.listType = .highest
            v2.viewModel.listType = .mostpopular
            
            listVCs.append(v)
            listVCs.append(v1)
            listVCs.append(v2)
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let v = viewController as? TourListViewController {
            switch v.viewModel.listType {
            case .latest :
                return nil
            case .highest :
                return listVCs[0]
            case .mostpopular :
                return listVCs[1]
            default:
                return nil
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let v = viewController as? TourListViewController {
            switch v.viewModel.listType {
            case .latest :
                return listVCs[1]
            case .highest :
                return listVCs[2]
            case .mostpopular :
                return nil
            default :
                return nil
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let v = pageViewController.viewControllers?.first as? TourListViewController {
            switch v.viewModel.listType {
            case .latest :
                self.curList.accept(0)
                break
            case .highest :
                self.curList.accept(1)
                break
            case .mostpopular :
                self.curList.accept(2)
                break
            default:
                break
            }
        }
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let t = item.tag
        self.curList.accept(t)
    }
    
}
