#import "User.h"
#import "Converter.h"
#import "NSString+HTML.h"

@implementation User

- (instancetype) initWithDictionary:(NSMutableDictionary*)dictionary
{
    if(self = [super init])
    {
        self.objectHidevisited = [[dictionary valueForKey:@"hidevisited"] boolValue];
        self.objectTagsIds = [Converter toListOfNSInteger:[dictionary objectForKey:@"tags"]];
        self.objectTags = [Converter toTags:[dictionary objectForKey:@"tagsobjects"]];
        self.objectFeeds = [Converter toFeeds:[dictionary objectForKey:@"feeds"]];
        self.objectFolders = [Converter toFolders:[dictionary objectForKey:@"folders"]];
    }
    return self;
}

@end
