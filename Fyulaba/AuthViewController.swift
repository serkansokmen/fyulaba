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

    @IBOutlet weak var continueButton: TWTRLogInButton!
    @IBOutlet weak var logoutButton: UIButton!

    @IBAction func handleLogout(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Twitter.sharedInstance().start(withConsumerKey: "XKl6zTVHVIDJqU05FzfGRDbGy",
                                       consumerSecret: "jcgiFoRqCfrLp15VeprNUg3faHLKUtBKuTECVQinEQGpXzkmkZ")

        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "ToSleepDiaries", sender: self)
        }

        continueButton.logInCompletion = { session, error in

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

                    // complete
                    self.performSegue(withIdentifier: "ToSleepDiaries", sender: self)
                }
            }
        }
    }

}
