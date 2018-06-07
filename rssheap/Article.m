#import "Article.h"
#import "NSString+HTML.h"

@implementation Article

- (instancetype) initWithDictionary:(NSMutableDictionary*)dictionary
{
    if(self = [super init])
    {
        self.objectId = [[dictionary valueForKey:@"Id"] integerValue];
        self.objectUrl = [dictionary valueForKey:@"Url"];
        self.objectFeedId = [[dictionary valueForKey:@"FeedId"] integerValue];
        self.objectFeedName = [[[dictionary objectForKey:@"Feed"] valueForKey:@"Name"] stringByDecodingHTMLEntities];
        self.objectFeedName = [self.objectFeedName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        self.objectName = [[dictionary valueForKey:@"Name"] stringByDecodingHTMLEntities];
        self.objectName = [self.objectName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        self.objectFavorites = [[dictionary valueForKey:@"FavoriteCount"] integerValue];
        self.objectVotes = [[dictionary valueForKey:@"LikesCount"] integerValue];
        self.objectViews = [[dictionary valueForKey:@"ViewsCount"] integerValue];
        self.objectTimeAgo = [dictionary valueForKey:@"TimeAgo"];
        self.objectTimeAgoLong = [dictionary valueForKey:@"TimeAgoLong"];
        self.objectIsMyFavorite = [[dictionary valueForKey:@"IsMyFavorite"] boolValue];
        self.objectIVoted = [[dictionary valueForKey:@"MyVotes"] integerValue] > 0;
        self.objectIDownVoted = [[dictionary valueForKey:@"MyVotes"] integerValue] < 0;
        self.objectShortUrl = [dictionary valueForKey:@"ShortUrl"];
        self.objectTweet = [dictionary valueForKey:@"Tweet"];
        self.objectBody = [dictionary valueForKey:@"Body"];
        
        NSMutableArray *tags = [[NSMutableArray alloc] init];
        NSArray *dictTags = [dictionary objectForKey:@"Tags"];
        for(int i = 0; i < dictTags.count; i++)
        {
            [tags addObject:[[dictTags objectAtIndex:i] valueForKey:@"Name"]];
        }
        self.objectTags = tags;
    }
    return self;
}

@end
