#import <UIKit/UIKit.h>

@interface ArticlesLeftDrawerController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblViewType;

- (IBAction)folderExpandClick:(id)sender;
@end
