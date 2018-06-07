#import <Foundation/Foundation.h>

@interface User : NSObject

@property NSInteger objectId;
@property BOOL objectHidevisited;
@property NSMutableArray *objectTagsIds;
@property NSMutableArray *objectTags;
@property NSMutableArray *objectFeeds;
@property NSMutableArray *objectFolders;

- (instancetype) initWithDictionary:(NSMutableDictionary*)dictionary;

@end
