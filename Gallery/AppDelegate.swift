//
//  AppDelegate.swift
//  Gallery
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow()
        let storyBoard = UIStoryboard(name: "Gallery", bundle: nil)
        
        let galleryViewController: UIViewController?
        if #available(iOS 13.0, *) {
            galleryViewController = storyBoard.instantiateViewController(identifier: "GalleryViewController")
        } else {
            galleryViewController = storyBoard.instantiateViewController(withIdentifier: "GalleryViewController")
        }
        
        let navigationViewController: UINavigationController? = UINavigationController(rootViewController: galleryViewController!)
        window?.rootViewController = navigationViewController
        
        return true
    }

}
