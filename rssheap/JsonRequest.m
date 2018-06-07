#import <Foundation/Foundation.h>
#import "JsonRequest.h"
#import "Utilities.h"
#import "AFNetworking.h"
#import <UIKit/UIKit.h>
#import "JGProgressHUD.h"

static NSString *url = @"https://www.rssheap.com";
static NSString *secretGuid = @"f123c52cd1e2442290c57f353250b232";
static NSString *version = @"v2";

@implementation JsonRequest

+ (void) postTo:(NSString *)toActionUrl onController:(UIViewController*)controller withLoading:(BOOL)showLoading data:(NSMutableDictionary *)json disableUserInput:(BOOL)disableUserInput  success:(void (^)(id))success
{
    if(json == nil) {
        json = [[NSMutableDictionary alloc] init];
    }
    
    [json setObject:secretGuid forKey:@"GUID"];
    [json setObject:[Utilities getUserGUID] forKey:@"USERGUID"];
    [json setObject:@"ios" forKey:@"platform"];

    NSString *postUrl = [NSString stringWithFormat:@"%@%@", url, toActionUrl];
    postUrl = [postUrl stringByReplacingOccurrencesOfString:@"/api/" withString:[[@"/api" stringByAppendingString:version] stringByAppendingString:@"/"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    JGProgressHUD *progress = nil;
    if(showLoading && controller != nil) {
        progress = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
        [progress showInView:controller.view];
        
        if(disableUserInput) {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        }
    }
    
    [manager POST: postUrl
             parameters:json
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 if(success) {
                     if(responseObject) {
                         success([[NSMutableDictionary alloc] initWithDictionary:responseObject]);
                     } else {
                         success(nil);
                     }
                     if(showLoading && controller != nil) {
                         [progress dismiss];
                         if(disableUserInput) {
                             [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                         }
                     }
                 }
                 
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"Error: %@", error);
                 if(showLoading && controller != nil) {
                     [progress dismiss];
                     if(disableUserInput) {
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }
                 }
             }
     ];
}

@end