#import "Folder.h"
#import "Converter.h"
#import "NSString+HTML.h"

@implementation Folder

- (instancetype) initWithDictionary:(NSMutableDictionary*)dictionary
{
    if(self = [super init])
    {
        self.objectId = [[dictionary valueForKey:@"Id"] integerValue];
        self.objectName = [[dictionary valueForKey:@"Name"] stringByDecodingHTMLEntities];
        self.objectFeeds = [Converter toFeeds:[dictionary objectForKey:@"Feeds"]];
    }
    return self;
}

@end
