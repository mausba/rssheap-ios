#import <Foundation/Foundation.h>

@interface Tag : NSObject

@property NSInteger objectId;
@property NSString *objectName;
@property NSString *objectDescription;
@property NSInteger objectArticlesCount;
@property NSInteger objectSubscribersCount;

- (instancetype) initWithDictionary:(NSMutableDictionary*)dictionary;

@end
