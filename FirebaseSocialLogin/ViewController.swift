
import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate {
  
  // Outlets
  @IBOutlet weak var userInfoLbl: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    GIDSignIn.sharedInstance()?.uiDelegate = self
    
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
  
  @IBAction func onGoogleSigninPressed(_ sender: Any) {
    GIDSignIn.sharedInstance()?.signIn()
  }
  
  @IBAction func onCustomGoogleSigninPressed(_ sender: Any) {
    GIDSignIn.sharedInstance()?.signIn()
  }
  
  func firebaseLogin(_ credential: AuthCredential) {
    Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
      if let error = error {
        debugPrint(error.localizedDescription)
        return
      } else {
        self.userInfoLbl.text = user?.user.email
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
        print("twitter")
      case FacebookAuthProviderID:
        print("facebook")
      default:
        break
      }
    }
  }
  
}

