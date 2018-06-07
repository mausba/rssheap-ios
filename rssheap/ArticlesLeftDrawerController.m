#import "ArticlesLeftDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "User.h"
#import "Utilities.h"
#import "Converter.h"
#import "ArticleViewTypeCell.h"
#import "FolderCell.h"
#import "Folder.h"
#import "FeedCell.h"
#import "TagDrawerCell.h"
#import "ActionDrawerCell.h"
#import "Feed.h"
#import "Tag.h"
#import "AppDelegate.h"
#import "FontAwesomeKit/FAKFontAwesome.h"
#import "ArticleListController.h"
#import "JsonRequest.h"

@interface ArticlesLeftDrawerController ()

@end

@implementation ArticlesLeftDrawerController

User *user;
NSMutableArray *viewTypes;
NSMutableArray *currentExpandedFolderIds;
NSMutableArray *foldersAndFeeds;
NSArray *actions;
BOOL myFeedsExpanded;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsZero;
    
    //remove floating section
    CGFloat dummyViewHeight = 30;
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, dummyViewHeight)];
    self.tableView.tableHeaderView = dummyView;
    self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);
    self.tableView.separatorColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    
    [self setupLeftMenuButton];
    user = [Utilities getUserFromSharedPreferences];
    viewTypes = [[NSMutableArray alloc] initWithObjects: @"This Week", @"This Month", @"By Votes", @"Untagged", @"Favorites", nil];
    
    if(user.objectFeeds.count > 0) {
        [viewTypes addObject:@"My Feeds"];
    }
    
    foldersAndFeeds = [[NSMutableArray alloc] initWithArray:user.objectFolders];
    currentExpandedFolderIds = [[NSMutableArray alloc] init];
    actions = [[NSArray alloc] initWithObjects: @"Edit Tags", @"Hide Visited Articles", @"Logoff", nil];
    
    [self.tableView reloadData];
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 5;  //the last section is just to give some padding
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1 && user.objectTags.count == 0) {
        return 0;
    }
    
    if(indexPath.section == 2 && user.objectFolders.count == 0) {
        return 0;
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0) {

        NSUInteger count = viewTypes.count;
        if(myFeedsExpanded) {
            count += user.objectFeeds.count;
        }
        return count;
    }
    else if(section == 1) {
        return user.objectTags.count;
    }
    else if(section == 2) {
        return foldersAndFeeds.count;
    }
    else if(section == 3) {
        return actions.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    
    //main views
    if(indexPath.section == 0) {
        static NSString *simpleTableIdentifier = @"viewType";
        
        ArticleViewTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
        if (cell == nil) {
            cell = [[ArticleViewTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        if(row < viewTypes.count) {
            NSString *viewType = [viewTypes objectAtIndex:indexPath.row];
            cell.lblViewType.text = viewType;
            if([viewType isEqualToString:@"This Week"]) {
                cell.icon.attributedText = [[FAKFontAwesome calendarIconWithSize:12] attributedString];
            }
            if([viewType isEqualToString:@"This Month"]) {
                cell.icon.attributedText = [[FAKFontAwesome calendarOIconWithSize:12] attributedString];
            }
            if([viewType isEqualToString:@"By Votes"]) {
                cell.icon.attributedText = [[FAKFontAwesome thumbsOUpIconWithSize:12] attributedString];
            }
            if([viewType isEqualToString:@"Untagged"]) {
                cell.icon.attributedText = [[FAKFontAwesome tagsIconWithSize:12] attributedString];
            }
            if([viewType isEqualToString:@"Favorites"]) {
                cell.icon.attributedText = [[FAKFontAwesome starOIconWithSize:12] attributedString];
            }
            if([viewType isEqualToString:@"My Feeds"]) {
                if(!myFeedsExpanded) {
                    cell.icon.attributedText = [[FAKFontAwesome angleRightIconWithSize:17] attributedString];
                } else {
                    cell.icon.attributedText = [[FAKFontAwesome angleDownIconWithSize:17] attributedString];
                }
                
                
                UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myFeedsExpandClick:)];
                tapGestureRecognizer.numberOfTapsRequired = 1;
                [cell.icon addGestureRecognizer:tapGestureRecognizer];
            }
            return cell;
        } else {
            //it is my feeds
            NSInteger feedIndex = row - viewTypes.count;
            Feed *feed = [user.objectFeeds objectAtIndex:feedIndex];
            
            static NSString *simpleTableIdentifier = @"feed";
            
            FeedCell *feedCell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            
            if (feedCell == nil) {
                feedCell = [[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            }
            
            feedCell.lblFeedName.text = feed.objectName;
            feedCell.favicon.image =[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: feed.objectFavicon]]];
            return feedCell;
        }
    }
    
    //tags
    if(indexPath.section == 1) {
        static NSString *tagCellIdentifier = @"tag";
        
        TagDrawerCell *cell = [tableView dequeueReusableCellWithIdentifier:tagCellIdentifier];
        
        if (cell == nil) {
            cell = [[TagDrawerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tagCellIdentifier];
        }
        
        Tag *tag = [user.objectTags objectAtIndex:row];
        
        cell.lblTagName.text = tag.objectName;
        cell.lblIcon.attributedText = [[FAKFontAwesome tagIconWithSize:12] attributedString];
        return cell;
    }
    
    //folders
    if(indexPath.section == 2) {
        
        static NSString *FolderCellIdentifier = @"folder";
        static NSString *FeedCellIdentifier = @"feed";
        
        NSObject *obj = [foldersAndFeeds objectAtIndex:row];
        BOOL isChild = [obj isKindOfClass:[Feed class]];
        
        UITableViewCell *cell;
        if (isChild) {
            cell = [tableView dequeueReusableCellWithIdentifier:FeedCellIdentifier];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:FolderCellIdentifier];
        }
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: isChild ? FeedCellIdentifier : FolderCellIdentifier];
        }
    
        if (isChild) {
            FeedCell *feedCell = (FeedCell *) cell;
            Feed *feed = (Feed *)obj;
            
            feedCell.lblFeedName.text = feed.objectName;
            feedCell.favicon.image =[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: feed.objectFavicon]]];
        } else {
            FolderCell *folderCell = (FolderCell *) cell;
            Folder *folder = (Folder *) obj;
            
            folderCell.lblFolderName.text = folder.objectName;
            
            if([currentExpandedFolderIds containsObject:[NSNumber numberWithInteger:folder.objectId]]) {
                folderCell.iconFolderExpand.attributedText = [[FAKFontAwesome angleDownIconWithSize:17] attributedString];
            } else {
                folderCell.iconFolderExpand.attributedText = [[FAKFontAwesome angleRightIconWithSize:17] attributedString];
            }
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(folderExpandClick:)];
            tapGestureRecognizer.numberOfTapsRequired = 1;
            [folderCell.iconFolderExpand addGestureRecognizer:tapGestureRecognizer];
            
            folderCell.iconFolderExpand.tag = folder.objectId;
            folderCell.folder = folder;
        }
        
        return cell;
    }
    
    //actions
    if(indexPath.section == 3) {
        static NSString *simpleTableIdentifier = @"action";
        
        ActionDrawerCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            cell = [[ActionDrawerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        NSString *action = [actions objectAtIndex:indexPath.row];
        
        cell.lblAction.text = action;
        
        if([action isEqualToString:@"Hide Visited Articles"] && user.objectHidevisited) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1 && user.objectTags.count == 0) {
        return 0;
    }
    
    if(section == 2 && user.objectFolders.count == 0) {
        return 0;
    }
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(section == 4) {
        UIView *view = [[UIView alloc] init];
        return view;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    ArticleListController *articleListController = (ArticleListController *) [(UINavigationController *)self.mm_drawerController.centerViewController topViewController];
    
    NSInteger row = indexPath.row;
    
    
    if(indexPath.section == 0) {
        
        if(row < viewTypes.count) {
            NSString *viewType = [viewTypes objectAtIndex:row];
            NSString *view = @"";
            if([viewType isEqualToString:@"This Week"]) {
                view = @"week";
            }
            if([viewType isEqualToString:@"This Month"]) {
                view = @"month";
            }
            if([viewType isEqualToString:@"By Votes"]) {
                view = @"votes";
            }
            if([viewType isEqualToString:@"Untagged"]) {
                view = @"untagged";
            }
            if([viewType isEqualToString:@"Favorites"]) {
                view = @"favorites";
            }
            if([viewType isEqualToString:@"My Feeds"]) {
                view = @"myfeeds";
            }
            
            articleListController.viewType = view;
            articleListController.title = viewType;
        } else {
            //it is my feeds
            NSInteger feedIndex = row - viewTypes.count;
            Feed *feed = [user.objectFeeds objectAtIndex:feedIndex];
            
            articleListController.viewType = [@"feed" stringByAppendingString:[NSString stringWithFormat: @"%ld", (long)feed.objectId]];
            articleListController.title = [feed.objectName stringByAppendingString:@" feed"];
        }
    }
    
    if(indexPath.section == 1) {
        Tag *tag = [user.objectTags objectAtIndex:row];
        
        articleListController.viewType = [@"tag" stringByAppendingString:[NSString stringWithFormat: @"%ld", (long)tag.objectId]];
        articleListController.title = [tag.objectName stringByAppendingString:@" feed"];
    }
    
    if(indexPath.section == 2) {
        
        BOOL isChild = [cell isKindOfClass:[FeedCell class]];

        if (isChild) {
            Feed *feed = (Feed *) [foldersAndFeeds objectAtIndex:row];
            
            articleListController.viewType = [@"feed" stringByAppendingString:[NSString stringWithFormat: @"%ld", (long)feed.objectId]];
            articleListController.title = [feed.objectName stringByAppendingString:@" feed"];
        } else {
            Folder *folder = (Folder *) [foldersAndFeeds objectAtIndex:row];
            articleListController.viewType = [@"folder" stringByAppendingString:[NSString stringWithFormat: @"%ld", (long)folder.objectId]];
            articleListController.title = [folder.objectName stringByAppendingString:@" feed"];
        }
    }
    
    if(indexPath.section == 3) {
        NSString *action = [actions objectAtIndex:row];
        if([action isEqualToString:@"Edit Tags"]) {
            [self performSegueWithIdentifier:@"tagsController2" sender:self];
        }
        
        if([action isEqualToString:@"Logoff"]) {
            [Utilities resetUserGuid];
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate resetWindowToInitialView];
            return;
        }
        
        if([action isEqualToString:@"Hide Visited Articles"]) {
            [JsonRequest postTo:@"/api/ToggleVisited" onController:self withLoading:YES data:nil disableUserInput:YES success:^(id responseJson) {
                if(responseJson) {
                    [Utilities addUserToSharedPreferences:responseJson];
                    user = [Utilities getUserFromSharedPreferences];
                    articleListController.page = 0;
                    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
                    [articleListController reloadArtiles];
                }
            }];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if(cell.accessoryType == UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            return;
        }
    }
    
    articleListController.page = 0;
    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    [articleListController reloadArtiles];
}

- (void)expandItemAtIndex:(NSInteger)index inSection:(NSInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray new];
    
    Folder *currentFolder = (Folder *) [foldersAndFeeds objectAtIndex:index];
    NSInteger insertPos = index + 1;
    for (int i = 0; i < [currentFolder.objectFeeds count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:insertPos++ inSection:section]];
    }
    
    [self refreshFoldersAndFeedsArray];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)collapseSubItemsAtIndex:(NSInteger)index inSection:(NSInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray new];
    NSArray *currentSubItems = ((Folder *) [foldersAndFeeds objectAtIndex:index]).objectFeeds;
    for (NSInteger i = index + 1; i <= index + [currentSubItems count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    [self refreshFoldersAndFeedsArray];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void) refreshFoldersAndFeedsArray {
    [foldersAndFeeds removeAllObjects];
    for(int i = 0; i < user.objectFolders.count; i++) {
        Folder *folder = [user.objectFolders objectAtIndex:i];
        
        [foldersAndFeeds addObject:folder];
        
        for(int j = 0; j < currentExpandedFolderIds.count; j++) {
            NSInteger expandedFolderId = [[currentExpandedFolderIds objectAtIndex:j] integerValue];
            
            if(folder.objectId == expandedFolderId) {
                [foldersAndFeeds addObjectsFromArray:folder.objectFeeds];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClick:(id)sender {
    UIViewController *centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ARTICLES_CONTROLLER"];
    
    if (centerViewController) {
        [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
    } else {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    }

}

- (IBAction)myFeedsExpandClick:(id)sender {
    UITapGestureRecognizer *recogniser = (UITapGestureRecognizer *)sender;
    
    UIView* view = recogniser.view;
    CGPoint loc = [recogniser locationInView:view];
    UILabel* lbl = (UILabel *) [view hitTest:loc withEvent:nil];
    
    ArticleViewTypeCell *myFeedsCell = (ArticleViewTypeCell *)[[lbl superview] superview];
    NSInteger row = [self.tableView indexPathForCell:myFeedsCell].row;
    
    [self.tableView beginUpdates];
    
    if(myFeedsExpanded) {
        myFeedsCell.icon.attributedText = [[FAKFontAwesome angleRightIconWithSize:17] attributedString];
        
        NSMutableArray *indexPaths = [NSMutableArray new];
        for (NSInteger i = row + 1; i <= row + user.objectFeeds.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        myFeedsExpanded = NO;
    } else {
        myFeedsCell.icon.attributedText = [[FAKFontAwesome angleDownIconWithSize:17] attributedString];
        
        NSMutableArray *indexPaths = [NSMutableArray new];
        NSInteger insertPos = row + 1;
        for (int i = 0; i < [user.objectFeeds count]; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:insertPos++ inSection:0]];
        }
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        myFeedsExpanded = YES;
    }
    
    [self.tableView endUpdates];
    
}


- (IBAction)folderExpandClick:(id)sender {
    UITapGestureRecognizer *recogniser = (UITapGestureRecognizer *)sender;
    
    UIView* view = recogniser.view;
    CGPoint loc = [recogniser locationInView:view];
    UILabel* lbl = (UILabel *) [view hitTest:loc withEvent:nil];
    
    FolderCell* folderCell = (FolderCell *)[[lbl superview] superview];
    NSInteger row = [self.tableView indexPathForCell:folderCell].row;
    
    [self.tableView beginUpdates];
    
    Folder *folder = folderCell.folder;
    
    if([currentExpandedFolderIds containsObject:[NSNumber numberWithInteger:folder.objectId]]) {
        [currentExpandedFolderIds removeObject:[NSNumber numberWithInteger:folder.objectId]];
        [self collapseSubItemsAtIndex:row inSection:2];
        folderCell.iconFolderExpand.attributedText = [[FAKFontAwesome angleRightIconWithSize:17] attributedString];
    } else {
        [currentExpandedFolderIds addObject:[NSNumber numberWithInteger:folder.objectId]];
        [self expandItemAtIndex:row inSection:2];
        folderCell.iconFolderExpand.attributedText = [[FAKFontAwesome angleDownIconWithSize:17] attributedString];
    }
    
    [self.tableView endUpdates];

}

@end
