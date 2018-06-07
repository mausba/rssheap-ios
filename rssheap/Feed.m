#import "Feed.h"
#import "NSString+HTML.h"

@implementation Feed

- (instancetype) initWithDictionary:(NSMutableDictionary*)dictionary
{
    if(self = [super init])
    {
        self.objectId = [[dictionary valueForKey:@"Id"] integerValue];
        self.objectName = [dictionary valueForKey:@"Name"];
        self.objectFavicon = [[dictionary valueForKey:@"Favicon"] stringByDecodingHTMLEntities];
    }
    return self;
}

@end
