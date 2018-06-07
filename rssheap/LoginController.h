#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>
#import <Google/SignIn.h>

@interface LoginController : UIViewController<GIDSignInDelegate, GIDSignInUIDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtUserName;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UIButton *btnLoginFacebook;
@property (strong, nonatomic) IBOutlet TWTRLogInButton *btnLoginTwitter;
@property (strong, nonatomic) IBOutlet UIButton *btnLoginGoogle;
@property (weak, nonatomic) IBOutlet UIView *placeHolderForUserAndPassword;

- (IBAction)loginClick:(id)sender;
- (IBAction)loginFacebookClick:(id)sender;
- (IBAction)loginTwitterClick:(id)sender;
- (IBAction)loginGoogleClick:(id)sender;

- (void) saveUserGuidAndRedirect:(NSMutableDictionary*) json;

@end

@class GPPSignInButton;
