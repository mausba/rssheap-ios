#import "TagsController.h"
#import "TagTableCell.h"
#import "JsonRequest.h"
#import "Converter.h"
#import "Utilities.h"
#import "Tag.h"
#import "User.h"
#import "MMDrawerController.h"
#import <Google/Analytics.h>

@interface TagsController ()

@end

@implementation TagsController

NSArray *tags;
User *user;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Roboto-Regular" size:16],
      NSFontAttributeName, nil]];
    
    self.load_more = YES;
    tags = [[NSArray alloc] init];
    
    [self loadTagsWithSuccess:^(id responseTags) {
        [self.tableView reloadData];
    }];
    
    user = [Utilities getUserFromSharedPreferences];
}

- (void)viewDidAppear:(BOOL)animated {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Tags"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tags == nil) {
        return 0;
    }
    return tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"tagCell";
    
    TagTableCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[TagTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    Tag *tag = [tags objectAtIndex:indexPath.row];
    cell.lblTagName.text = tag.objectName;
    cell.lblTagDescription.text = tag.objectDescription;
    cell.lblArticlesCount.text = [NSString stringWithFormat:@"%ld articles", (long) tag.objectArticlesCount];
    cell.lblSubscribersCount.text = [NSString stringWithFormat:@"%ld subscribers", (long) tag.objectSubscribersCount];
    
    if([user.objectTagsIds containsObject:[NSNumber numberWithInteger:tag.objectId]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:0];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    Tag *tag = [tags objectAtIndex:indexPath.row];
    [self addRemoveTag:tag.objectId success:^{ }];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    Tag *tag = [tags objectAtIndex:indexPath.row];
    [self addRemoveTag:tag.objectId success:^() { }];
}

- (void)addRemoveTag : (NSInteger) tagId success:(void (^)())success
{
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [post setObject:[NSNumber numberWithInteger:tagId] forKey:@"id"];
    [JsonRequest postTo:@"/api/AddRemoveTag" onController:self withLoading:FALSE data:post disableUserInput:YES success:^(id responseJson) {
        if(responseJson) {
            [Utilities addUserToSharedPreferences:responseJson];
            success();
        }
    }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(tags.count == 0 || scrollView != self.tableView || !self.load_more) {
        return;
    }

    CGFloat height = scrollView.frame.size.height;
    CGFloat contentYoffset = scrollView.contentOffset.y;
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset - 150;
    
    if(distanceFromBottom < height)
    {
        if(scrollView == self.tableView){
            self.load_more = NO;
            self.page++;
            
            [self loadTagsWithSuccess:^(id responseTags) {
                if([responseTags count] > 0) {
                    self.load_more = YES;
                    [self.tableView reloadData];
                }
            }];
        }
    }
}

-(void) loadTagsWithSuccess : (void (^)(id))success
{
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [post setObject:[NSString stringWithFormat:@"%ld", (long) self.page] forKey:@"page"];
    [JsonRequest postTo:@"/api/GetTags" onController:self withLoading:FALSE data:post disableUserInput:YES success:^(id responseJson) {
        if(responseJson) {
            NSArray *responseTags = [Converter toTags:[responseJson objectForKey:@"tags"]];
            tags = [tags arrayByAddingObjectsFromArray:responseTags];
            success(responseTags);
        }
    }];
}

- (IBAction)btnDoneClick:(id)sender {
    MMDrawerController *destinationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"drawerController"];
    // Instantitate and set the center view controller.
    UIViewController *centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ARTICLES_CONTROLLER"];
    [destinationViewController setCenterViewController:centerViewController];
    
    // Instantiate and set the left drawer controller.
    UIViewController *leftDrawerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SIDE_DRAWER_CONTROLLER"];
    [destinationViewController setLeftDrawerViewController:leftDrawerViewController];
    
    [destinationViewController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [destinationViewController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self presentViewController:destinationViewController animated:YES completion:nil];
}

@end
