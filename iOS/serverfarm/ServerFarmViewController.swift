//
//  ServerFarmViewController.swift
//  serverfarm
//
//  Created by Washington Family on 2/7/17.
//  Copyright © 2017 Washington. All rights reserved.
//

import UIKit
import SocketIO
import MediaPlayer

class ServerFarmViewController:  UIPageViewController {
    override func viewDidLayoutSubviews() {
        for subView in self.view.subviews {
            if subView is UIScrollView {
                subView.frame = self.view.bounds
            } else if subView is UIPageControl {
                self.view.bringSubview(toFront: subView)
            }
        }
        super.viewDidLayoutSubviews()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        listenVolumeButton()
        
         dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }

       

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newRoomViewController("kitchen"),
                self.newRoomViewController("familyRoom"),
                self.newRoomViewController("diningRoom"),
                self.newRoomViewController("upstairsBath"),
                self.newRoomViewController("guestBath"),
                self.newRoomViewController("patio"),
                self.newRoomViewController("basement")]
    }()
    
    fileprivate func newRoomViewController(_ room: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(room)View")
    }
    
    func listenVolumeButton() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error initializing up volume button")
        }
        
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
        
        // Hide Volume HUD view
        let volumeView: MPVolumeView = MPVolumeView(frame: CGRect.zero)
        
        view.addSubview(volumeView)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            print(AVAudioSession.sharedInstance().outputVolume)
        }
    }


}

// MARK: UIPageViewControllerDataSource

extension ServerFarmViewController: UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
    func pageViewController(_ viewControllerAfterpageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
   

        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
    
}
