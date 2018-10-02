
import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import TwitterKit

class ViewController: UIViewController, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {

  // Outlets
  @IBOutlet weak var userInfoLbl: UILabel!
  @IBOutlet weak var facebookLoginBtn: FBSDKLoginButton!
  @IBOutlet weak var twitterLoginView: UIView!
  
  // Variables
  let fbLoginManager = FBSDKLoginManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    GIDSignIn.sharedInstance()?.uiDelegate = self
    facebookLoginBtn.delegate = self
    
    
    let twitterButton = TWTRLogInButton { (session, error) in
      if let error = error {
        debugPrint("Error logging in with Twitter: \(error)")
      }
      if let session = session {
        let credential = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
        self.firebaseLogin(credential)
      }
    }
    twitterButton.center.x = twitterLoginView.center.x
    twitterLoginView.addSubview(twitterButton)
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    Auth.auth().addStateDidChangeListener { (auth, user) in
      if user == nil {
        self.userInfoLbl.text = ""
      } else {
        self.userInfoLbl.text = "Welcome \(user?.email ?? "")"
      }
    }
  }
  
  @IBAction func onLogoutBtnPressed(_ sender: Any) {
    let firebaseAuth = Auth.auth()
    do {
      logoutSocial()
      try firebaseAuth.signOut()
    } catch let error as NSError {
      debugPrint("Error loggin out: \(error)")
    }
  }
  
  // Google Login
  @IBAction func onGoogleSigninPressed(_ sender: Any) {
    GIDSignIn.sharedInstance()?.signIn()
  }
  
  @IBAction func onCustomGoogleSigninPressed(_ sender: Any) {
    GIDSignIn.sharedInstance()?.signIn()
  }
  
  // Facebook Login
  @IBAction func onCustomFBLoginPressed(_ sender: Any) {
    fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
      if let error = error {
        debugPrint("Error logging in with FB: \(error)")
      } else if (result?.isCancelled)! {
        debugPrint("FB Login cancelled")
      } else {
        let credential = FacebookAuthProvider.credential(withAccessToken: (FBSDKAccessToken.current()?.tokenString)!)
        self.firebaseLogin(credential)
      }
    }
  }
  
  func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    if let error = error {
      debugPrint("Error logging in with FB: \(error)")
      return
    } else {
      let credential = FacebookAuthProvider.credential(withAccessToken: result.token.tokenString)
      firebaseLogin(credential)
    }
  }
  
  func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    // Handle logout
  }
  
  // Twitter
  @IBAction func onCustomTwitterBtnPressed(_ sender: Any) {
    TWTRTwitter.sharedInstance().logIn { (session, error) in
      if let error = error {
        debugPrint("Error logging in with Twitter: \(error)")
      }
      if let session = session {
        let credential = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
        self.firebaseLogin(credential)
      }
    }
  }
  
  // Firebase
  
  func firebaseLogin(_ credential: AuthCredential) {
    Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
      if let error = error {
        debugPrint(error.localizedDescription)
        return
      } else {
        self.userInfoLbl.text = user?.user.uid
      }
      
    }
  }
  
  func logoutSocial() {
    guard let user = Auth.auth().currentUser else { return }
    for info in user.providerData {
      switch info.providerID {
      case GoogleAuthProviderID:
        GIDSignIn.sharedInstance()?.signOut()
      case TwitterAuthProviderID:
        let store = TWTRTwitter.sharedInstance().sessionStore
        if let userID = store.session()?.userID {
          store.logOutUserID(userID)
        }
      case FacebookAuthProviderID:
        fbLoginManager.logOut()
      default:
        break
      }
    }
  }
  
}

