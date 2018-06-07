#import <Foundation/Foundation.h>

@interface Converter : NSObject

+ (NSMutableArray*) toTags : (NSArray*) dictionaryArray;
+ (NSMutableArray*) toFeeds : (NSArray*) dictionaryArray;
+ (NSMutableArray*) toFolders : (NSArray*) dictionaryArray;
+ (NSMutableArray*) toArticles : (NSArray*) dictionaryArray;
+ (NSMutableArray*) toListOfNSInteger : (NSArray*) dictionaryArray;

@end
