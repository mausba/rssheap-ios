#import <UIKit/UIKit.h>

@interface TagTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTagName;
@property (weak, nonatomic) IBOutlet UILabel *lblTagDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblSubscribersCount;
@property (weak, nonatomic) IBOutlet UILabel *lblArticlesCount;

@end
