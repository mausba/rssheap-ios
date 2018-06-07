#import <Foundation/Foundation.h>

@interface Folder : NSObject

@property NSInteger objectId;
@property NSString *objectName;
@property NSArray *objectFeeds;

- (instancetype) initWithDictionary:(NSMutableDictionary*)dictionary;

@end
