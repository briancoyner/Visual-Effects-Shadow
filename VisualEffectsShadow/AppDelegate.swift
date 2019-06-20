//
//  Created by Brian M Coyner on 5/11/17.
//  Copyright © 2017 Brian Coyner. All rights reserved.
//

import Foundation
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow? = UIWindow()
}

extension AppDelegate {

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let mainViewController = MainViewController()
        window?.rootViewController = UINavigationController(rootViewController: mainViewController)
        window?.makeKeyAndVisible()

        return true
    }
}
