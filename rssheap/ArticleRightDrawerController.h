#import <UIKit/UIKit.h>
#import "Article.h"

@interface ArticleRightDrawerController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property Article *article;

@end
