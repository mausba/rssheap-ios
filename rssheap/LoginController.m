#import "LoginController.h"
#import "Utilities.h"
#import "JsonRequest.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <TwitterKit/TwitterKit.h>
#import "MMDrawerController.h"
#import "ArticleListController.h"
#import <Google/Analytics.h>
#import <Google/SignIn.h>

@interface LoginController ()
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    
    //if there is a guid user is already authenticated
    NSString *userGuid = [Utilities getUserGUID];
    if(userGuid.length > 0 && [Utilities isDeviceOnline]) {
        [JsonRequest postTo:@"/api/RefreshUserInfo" onController:self withLoading:TRUE data:nil disableUserInput:YES success:^(id responseJson) {
            if(responseJson) {
                [Utilities addUserToSharedPreferences:responseJson];
                User *user = [Utilities getUserFromSharedPreferences];
                
                [self redirectUser:user];
            } else {
                [Utilities showToastOn:self.view withMessage:@"There was an error in processing the request"];
            }
        }];
    }
    
    self.btnLogin.backgroundColor = [UIColor colorWithRed:(105/255.0) green:(201/255.0) blue:(72/255.0) alpha:1];
    self.btnLoginFacebook.backgroundColor = [UIColor colorWithRed:(86/255.0) green:(129/255.0) blue:(209/255.0) alpha:1];
    self.btnLoginTwitter.backgroundColor = [UIColor colorWithRed:(83/255.0) green:(179/255.0) blue:(239/255.0) alpha:1];
    self.btnLoginGoogle.backgroundColor = [UIColor colorWithRed:(224/255.0) green:(76/255.0) blue:(51/255.0) alpha:1];
    
    [Utilities addBorderTo:self.btnLogin];
    [Utilities addBorderTo:self.btnLoginFacebook];
    [Utilities addBorderTo:self.btnLoginTwitter];
    [Utilities addBorderTo:self.btnLoginGoogle];
    [Utilities addBorderTo:self.placeHolderForUserAndPassword];
    
    //twitter login button
    __weak id weakSelf = self;
    self.btnLoginTwitter.logInCompletion = ^(TWTRSession *session, NSError *error) {
        if(!error) {
            NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
            [post setObject:session.userID forKey:@"id"];
            [post setObject:session.userName forKey:@"screenName"];
            [post setObject:@"twitter" forKey:@"provider"];
            
            [JsonRequest postTo:@"/api/GetUser" onController:weakSelf withLoading:TRUE data:post disableUserInput:YES success:^(id responseJson) {
                [weakSelf saveUserGuidAndRedirect:responseJson];
            }];

        }
    };
    [self.btnLoginTwitter setImageEdgeInsets:UIEdgeInsetsMake(2, 50, 2, 20)];
}

- (void)viewDidAppear:(BOOL)animated {
    if(![Utilities isDeviceOnline])
    {
        [Utilities showToastOn:self.view withMessage:@"No internet connection"];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Login"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginClick:(id)sender {
    
    NSString *email = self.txtUserName.text;
    NSString *password = self.txtPassword.text;
    
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [post setValue:email forKey:@"username"];
    [post setValue:password forKey:@"password"];
    [post setValue:@"internal" forKey:@"provider"];
    
    [JsonRequest postTo:@"/api/GetUser" onController:self withLoading:TRUE data:post disableUserInput:YES success:^(id responseJson) {
        if(!responseJson) {
            [Utilities showToastOn:self.view withMessage:@"Invalid username or password"];
        } else {
            [self saveUserGuidAndRedirect:responseJson];
        }
    }];
    
}

- (IBAction)loginFacebookClick:(id)sender {
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [loginManager logInWithReadPermissions:nil fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if(!error) {
            
            NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"id,name,email,first_name,last_name" forKey:@"fields"];
            
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                     NSMutableDictionary *jsonProfile = [[NSMutableDictionary alloc] init];
                     [jsonProfile setObject:result[@"id"] forKey:@"id"];
                     [jsonProfile setObject:result[@"first_name"] forKey:@"firstname"];
                     [jsonProfile setObject:result[@"email"] forKey:@"email"];
                     [jsonProfile setObject:result[@"name"] forKey:@"name"];
                     [jsonProfile setObject:result[@"last_name"] forKey:@"lastname"];
                     [jsonProfile setObject:@"facebook" forKey:@"provider"];
                     
                     [JsonRequest postTo:@"/api/GetUser" onController:self withLoading:TRUE data:jsonProfile disableUserInput:YES success:^(id responseJson) {
                         [self saveUserGuidAndRedirect:responseJson];
                     }];
                 } else {
                     [Utilities showToastOn:self.view withMessage:[error localizedDescription]];
                 }
             }];
            
            
        } else {
            [Utilities showToastOn:self.view withMessage:[error localizedDescription]];
        }
        
    }];
}

- (IBAction)loginTwitterClick:(id)sender {
}

- (IBAction)loginGoogleClick:(id)sender {
    [[GIDSignIn sharedInstance] signIn];
}

- (void) saveUserGuidAndRedirect:(NSMutableDictionary*) json
{
    if(json) {
        NSString *guid = [json objectForKey:@"guid"];
        
        [Utilities addUserGUID: guid];
        [JsonRequest postTo:@"/api/RefreshUserInfo" onController:self withLoading:TRUE data:nil disableUserInput:YES success:^(id responseJson) {
            if(responseJson) {
                [Utilities addUserToSharedPreferences:responseJson];
                [Utilities addUserToSharedPreferences:responseJson];
                User *user = [Utilities getUserFromSharedPreferences];
                
                [self redirectUser:user];

            } else {
                [Utilities showToastOn:self.view withMessage:@"There was an error in processing the request"];
            }
        }];
    }
}

-(void) redirectUser:(User *) user {
    if(user.objectTagsIds.count == 0) {
        UIViewController *tagsController = [self.storyboard instantiateViewControllerWithIdentifier:@"tagsController"];
        [self presentViewController:tagsController animated:YES completion:nil];
    } else {
        MMDrawerController *destinationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"drawerController"];
        // Instantitate and set the center view controller.
        UIViewController *centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ARTICLES_CONTROLLER"];
        [destinationViewController setCenterViewController:centerViewController];
        
        // Instantiate and set the left drawer controller.
        UIViewController *leftDrawerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SIDE_DRAWER_CONTROLLER"];
        [destinationViewController setLeftDrawerViewController:leftDrawerViewController];
        
        [destinationViewController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
        [destinationViewController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
        
        [self presentViewController:destinationViewController animated:YES completion:nil];
    }
}

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations on signed in user here.
    NSString *userId = user.userID;                  // For client-side use only!
    //NSString *idToken = user.authentication.idToken; // Safe to send to the server
    //NSString *fullName = user.profile.name;
    //NSString *givenName = user.profile.givenName;
    //NSString *familyName = user.profile.familyName;
    NSString *email = user.profile.email;
    
    NSMutableDictionary *jsonProfile = [[NSMutableDictionary alloc] init];
    [jsonProfile setObject:userId forKey:@"id"];
    [jsonProfile setObject:@"google" forKey:@"provider"];
    [jsonProfile setObject:email forKey:@"email"];
    
    [JsonRequest postTo:@"/api/GetUser" onController:self withLoading:TRUE data:jsonProfile disableUserInput:YES success:^(id responseJson) {
        [self saveUserGuidAndRedirect:responseJson];
    }];
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
}

@end
