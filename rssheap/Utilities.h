#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "User.h"

@interface Utilities : NSObject

+ (void) showAlert : (NSString *) message;
+ (NSString *) getUserGUID;
+ (void) addUserGUID : (NSString *) guid;
+ (void) addUserToSharedPreferences : (NSMutableDictionary*) user;
+ (User *) getUserFromSharedPreferences;
+ (void) resetUserGuid;
+ (void) addBorderTo : (UIView*) view;
+ (void) showToastOn : (UIView*) view withMessage : (NSString*) message;
+ (BOOL) isDeviceOnline;
+ (NSString *) dictionaryToJson : (NSMutableDictionary *) dictionary;
+ (NSMutableDictionary *) dictionaryFromJson : (NSString *) json;
+ (NSString *) formatCount : (NSInteger) count;
+ (BOOL)isLandscapeOrientation;
+ (BOOL) isiPad;

@end
