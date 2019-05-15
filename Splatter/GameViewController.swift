//
//  GameViewController.swift
//  Splatter
//
//  Created by Thomas Perritt on 07/05/2019.
//  Copyright © 2019 Thomas Perritt. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController, GADInterstitialDelegate {

    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.delegate = self
        
        let request = GADRequest()
        interstitial.load(request)
        
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
        else {
            print("Ad wasn't ready")
        }
        
        interstitial = createAndLoadInterstitial()

        if let view = self.view as! SKView? {
            
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            scene.size = self.view.bounds.size
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAd), name: NSNotification.Name(rawValue: "ShowInterAdKey"), object: nil)
    }
    
    @objc func showAd(){
        
        print("Attempting to Show Ad")
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
        else {
            print("Ad wasn't ready")
        }
        interstitial = createAndLoadInterstitial()
    }
    
    @objc func createAndLoadInterstitial() -> GADInterstitial {
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }

    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }

    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }

    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
