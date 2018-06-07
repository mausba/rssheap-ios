#import <Foundation/Foundation.h>

@interface Article : NSObject

@property NSInteger objectId;
@property NSString *objectUrl;
@property NSString *objectName;
@property NSString *objectBody;
@property NSString *objectTimeAgo;
@property NSString *objectTimeAgoLong;
@property BOOL objectIsMyFavorite;
@property BOOL objectIVoted;
@property BOOL objectIDownVoted;
@property NSString *objectShortUrl;
@property NSString *objectTweet;
@property NSInteger objectVotes;
@property NSInteger objectViews;
@property NSInteger objectFavorites;
@property NSDate *objectPublished;
@property NSInteger objectFeedId;
@property NSString *objectFeedName;
@property NSArray *objectTags;

- (instancetype) initWithDictionary:(NSMutableDictionary*)dictionary;

@end
