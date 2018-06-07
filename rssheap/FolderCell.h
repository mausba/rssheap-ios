#import <UIKit/UIKit.h>
#import "Folder.h"

@interface FolderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblFolderName;
@property (weak, nonatomic) IBOutlet UILabel *iconFolderExpand;

@property Folder *folder;
@property NSInteger currentIndex;

@end
