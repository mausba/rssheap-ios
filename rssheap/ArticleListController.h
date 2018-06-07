#import <UIKit/UIKit.h>

@interface ArticleListController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *titleBar;


@property(nonatomic) int page;
@property(nonatomic) NSString *viewType;

@property(nonatomic) BOOL load_more;

- (void)reloadArtiles;

@end
