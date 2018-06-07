#import "Tag.h"
#import "NSString+HTML.h"

@implementation Tag

- (instancetype) initWithDictionary:(NSMutableDictionary*)dictionary
{
    if(self = [super init])
    {
        self.objectId = [[dictionary valueForKey:@"Id"] integerValue];
        self.objectName = [[dictionary valueForKey:@"Name"] stringByDecodingHTMLEntities];
        self.objectDescription = [[dictionary valueForKey:@"Description"] stringByDecodingHTMLEntities];
        self.objectSubscribersCount = [[dictionary valueForKey:@"SubscribersCount"] integerValue];
        self.objectArticlesCount = [[dictionary valueForKey:@"ArticlesCount"] integerValue];
    }
    return self;
}

@end
