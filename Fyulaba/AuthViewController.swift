//
//  DocumentViewController.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 17/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import TwitterKit
import Firebase
import Cartography

class AuthViewController: UIViewController {

    private var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        Twitter.sharedInstance().start(withConsumerKey: "XKl6zTVHVIDJqU05FzfGRDbGy",
                                       consumerSecret: "jcgiFoRqCfrLp15VeprNUg3faHLKUtBKuTECVQinEQGpXzkmkZ")


        self.view.addSubview(self.twitterLogInButton)
        constrain(self.twitterLogInButton) {
            $0.center == $0.superview!.center
        }
    }
    
    private lazy var twitterLogInButton: UIButton = {
        let button = TWTRLogInButton(logInCompletion: { session, error in

            if error != nil {
                print(error!.localizedDescription)
                return
            }

            if let session = session {
                let authToken = session.authToken
                let authTokenSecret = session.authTokenSecret

                let credential = TwitterAuthProvider.credential(withToken: session.authToken,
                                                                secret: session.authTokenSecret)

                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    self.user = user
                }
            }
        })
        return button
    }()
}
