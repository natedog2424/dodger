//
//  GameViewController.swift
//  gameTest
//
//  Created by Nathan Anderson on 3/23/18.
//  Copyright © 2018 Nathan Anderson. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds


class GameViewController: UIViewController {
    
//IBOutlets for menu buttons
    @IBOutlet var dodgeLogo: UIImageView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var UIBlur: UIVisualEffectView!
    @IBOutlet var themeButton: UIButton!
    
     //let gameScene = GameScene()
 
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.performSegue(withIdentifier: "callMenu", sender: nil)
        
        return true
    }
    
    
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        //bannerView.adUnitID = "ca-app-pub-7491086934292934/4952955033" Real ID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func callMenu(){
       
        //playButton.isHidden = false
       // present(GameViewController() as UIViewController, animated: false, completion: nil)
       
    }
    
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        

        

        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                
                // Present the scene
                view.presentScene(scene)
                UIView.animate(withDuration: 0.5, animations: {
                    self.UIBlur.alpha = 0
                })
                
            }
            
            view.ignoresSiblingOrder = true
            
            
            //view.showsFPS = true
            //view.showsNodeCount = true
            
        }
        
    }
    
}
