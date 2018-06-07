#import "Converter.h"
#import "Tag.h"
#import "Feed.h"
#import "Folder.h"
#import "Article.h"

@implementation Converter

+ (NSMutableArray*) toTags : (NSArray*) dictionaryArray
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for(id key in dictionaryArray)
    {
        Tag *tag = [[Tag alloc] initWithDictionary:key];
        [result addObject:tag];
    }
    return result;
}

+ (NSMutableArray*) toFeeds : (NSArray*) dictionaryArray
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(int i = 0; i < dictionaryArray.count; i++)
    {
        [result addObject:[[Feed alloc] initWithDictionary:[dictionaryArray objectAtIndex:i]]];
    }
    return result;
}

+ (NSMutableArray*) toFolders : (NSArray*) dictionaryArray
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(int i = 0; i < dictionaryArray.count; i++)
    {
        [result addObject:[[Folder alloc] initWithDictionary:[dictionaryArray objectAtIndex:i]]];
    }
    return result;
}

+ (NSMutableArray*) toArticles : (NSArray*) dictionaryArray
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(int i = 0; i < dictionaryArray.count; i++)
    {
        [result addObject:[[Article alloc] initWithDictionary:[dictionaryArray objectAtIndex:i]]];
    }
    return result;
}

+ (NSMutableArray*) toListOfNSInteger : (NSArray*) dictionaryArray
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(int i = 0; i < dictionaryArray.count; i++)
    {
        [result addObject:[dictionaryArray objectAtIndex:i]];
    }
    return result;
}

@end
