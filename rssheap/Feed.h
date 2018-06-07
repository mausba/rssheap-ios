#import <Foundation/Foundation.h>

@interface Feed : NSObject

@property NSInteger objectId;
@property NSString *objectName;
@property NSString *objectFavicon;

- (instancetype) initWithDictionary:(NSMutableDictionary*)dictionary;

@end
