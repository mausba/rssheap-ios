#import "MyApplication.h"

@implementation MyApplication

- (BOOL)openURL:(NSURL*)url {
    
    NSURL *googlePlusURL = [[NSURL alloc] initWithString:@"gplus://plus.google.com/"];
    
    BOOL hasGPPlusAppInstalled = [[UIApplication sharedApplication] canOpenURL:googlePlusURL];
    
    
    if(!hasGPPlusAppInstalled)
    {
        if ([[url absoluteString] hasPrefix:@"googlechrome-x-callback:"]) {
            
            return NO;
            
        } else if ([[url absoluteString] hasPrefix:@"https://accounts.google.com/o/oauth2/auth"]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationOpenGoogleAuthNotification object:url];
            return NO;
            
        }
    }
    
    
    return [super openURL:url];
}

@end
