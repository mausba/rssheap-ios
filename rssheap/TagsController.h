#import <UIKit/UIKit.h>

@interface TagsController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDone;

@property(nonatomic) int page;
@property(nonatomic) BOOL load_more;

-(void) addRemoveTag : (NSInteger)tagId success:(void (^)())success;
-(void) loadTagsWithSuccess : (void (^)(id))success;
- (IBAction)btnDoneClick:(id)sender;

@end
