//
//  SideSettingViewController.swift
//  Networking
//
//  Created by Antelis on 2019/4/15.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

var drawerOffsetRatio : CGFloat = 0.55

class SideSettingViewController: UIViewController, DrawerVCProtocol {
    @IBOutlet weak var mainVCContainer : UIView?
    @IBOutlet weak var drawerView : UIView?
    @IBOutlet weak var drawerRightConstraint: NSLayoutConstraint?
    var tap : UITapGestureRecognizer?
    
    var vc : UINavigationController?//UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMainVCView()
        setupTapOff()
    }
    
    private func setupTapOff() {
        tap = UITapGestureRecognizer(target: self, action: #selector(self.tapToOff(_:)))
        if let tap = tap {
            tap.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tap)
        }
    }
    @objc func tapToOff(_ tap : UITapGestureRecognizer) {
        if isDrawerShown {
            self.switchDrawer()
        }
    }
    private func setupMainVCView() {
        if let centerView = self.mainVCContainer {
            
            centerView.layer.shadowColor = UIColor.black.cgColor
            centerView.layer.shadowRadius = 32
            centerView.layer.shadowOpacity = 0.4
            centerView.layer.masksToBounds = false
            centerView.translatesAutoresizingMaskIntoConstraints = false
        }
        if let drawerView = self.drawerView  {
            drawerView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    
    private var isDrawerShown : Bool = false
    
    private func applyTransforms() {
        if let centerView = self.mainVCContainer,
            let c = self.drawerRightConstraint{
            
            let centerWidth = centerView.bounds.width
            let sideWidth = centerWidth
            let scaledCenterViewHorizontalOffset = (sideWidth*drawerOffsetRatio - (centerWidth - drawerOffsetRatio * centerWidth) / 2.0)
            
            let centerTranslate = CGAffineTransform(translationX: scaledCenterViewHorizontalOffset, y: 0.0)
            let centerScale = CGAffineTransform(scaleX: 0.8, y: 0.8)
            centerView.transform = centerScale.concatenating(centerTranslate)            
            c.constant = 200+(scaledCenterViewHorizontalOffset/drawerOffsetRatio - 200)/2
        }
    }
    private func restoreTransforms() {
        if let centerView = self.mainVCContainer,
            let c = self.drawerRightConstraint {
            centerView.transform = CGAffineTransform.identity
            c.constant = 0
        }
    }
    
    @IBAction func showSetting(_ sender: Any?) {
        //print("showSetting")
        if let ss = self.vc {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let fv  = storyboard.instantiateViewController(withIdentifier: "MyFavListVC") as? MyFavListViewController {
                ss.pushViewController(fv, animated: true)
                self.switchDrawer()
                
            } else {
                self.switchDrawer()
            }
            
        }
        
    }
    
    func switchDrawer(){
        //print("SWitch Drawer!!")
        if let _ = self.mainVCContainer {
            if isDrawerShown {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 9.8, options: .curveLinear, animations: {
                    self.restoreTransforms()
                }, completion: { finished  in
                    
                })
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 9.8, options: .curveLinear, animations: {
                    self.applyTransforms()
                }, completion: { finished  in
                    
                })
            }
        }
        isDrawerShown = !isDrawerShown
        if isDrawerShown {
            if let tap = tap {
                tap.isEnabled = true
                tap.cancelsTouchesInView = true
            }
        } else {
            if let tap = tap {
                tap.cancelsTouchesInView = false
                tap.isEnabled = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let s = segue.identifier, s == "MainVCEmbed",
            let v = segue.destination as? UINavigationController,
            let ss = v.viewControllers.first as? BaseViewController {
            ss.drawerVC = self
            self.vc = v
        }
    }
}


