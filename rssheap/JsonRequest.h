#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JsonRequest : NSObject

+ (void) postTo:(NSString *)toActionUrl onController:(UIViewController*)controller withLoading:(BOOL)showLoading data:(NSMutableDictionary *)json disableUserInput:(BOOL)disableUserInput success:(void (^)(id))success;

@end