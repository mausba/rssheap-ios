#import "Utilities.h"
#import "Converter.h"
#import "User.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIView+Toast.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

@implementation Utilities

+(void)showAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This is the title"
                                                    message:message
                                                    delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
    [alert show];
}

+ (NSString *) getUserGUID
{
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString *guid = [preferences stringForKey:@"guid"];
    if(guid == nil) {
        return @"";
    }
    return guid;
}

+ (void) addUserGUID:(NSString *) guid
{
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:guid forKey:@"guid"];
}

+ (void) addUserToSharedPreferences : (NSMutableDictionary*) user
{
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:[Utilities dictionaryToJson:user] forKey:@"user"];
}

+ (User *) getUserFromSharedPreferences
{
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSString *userJsonString = [preferences stringForKey:@"user"];
    if(userJsonString == nil) {
        return nil;
    }
    NSMutableDictionary *dict = [Utilities dictionaryFromJson:userJsonString];
    User *user = [[User alloc] initWithDictionary:dict];
    return user;
}

+ (void) resetUserGuid
{
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    NSDictionary* dictionary = [preferences dictionaryRepresentation];
    for (id key in dictionary) {
        [preferences removeObjectForKey:key];
    }
}

+ (void) addBorderTo : (UIView*) view
{
    //rounded corners for the buttons
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
    view.layer.mask = maskLayer;
}

+ (void) showToastOn:(UIView *)view withMessage:(NSString *)message
{
    [view makeToast:message duration:2 position:CSToastPositionCenter];
}

+ (BOOL) isDeviceOnline
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL)
    {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
        CFRelease(reachability);
    }
    
    return NO;
}

+ (NSString *) dictionaryToJson : (NSMutableDictionary *) dictionary
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (NSMutableDictionary *) dictionaryFromJson : (NSString *) json
{
    NSError *jsonError;
    NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:objectData
                                                           options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    return dictionary;
}

+ (NSString *) formatCount : (NSInteger) count
{
    if(count >= 1000) {
        return [NSString stringWithFormat:@"%ldk", count / 1000];
    }
    if(count >= 1000000) {
        return [NSString stringWithFormat:@"%ldm", count / 1000000];
    }
    return [NSString stringWithFormat:@"%ld", count];
}

+ (BOOL)isLandscapeOrientation {
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

+ (BOOL) isiPad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

@end