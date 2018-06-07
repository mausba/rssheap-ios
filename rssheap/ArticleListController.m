#import "ArticleListController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "Utilities.h"
#import "Article.h"
#import "ArticleCell.h"
#import "JsonRequest.h"
#import "Converter.h"
#import "Tag.h"
#import "ArticleController.h"
#import <Google/Analytics.h>

@interface ArticleListController ()

@end

NSMutableArray *articles;

@implementation ArticleListController

NSMutableArray *fullArticles;
NSInteger currentIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Roboto-Regular" size:16],
      NSFontAttributeName, nil]];
    
    if(![Utilities isDeviceOnline]) {
        UINavigationController *navigationController = self.navigationController;
        [navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self setupLeftMenuButton];
    articles = [[NSMutableArray alloc] init];
    self.tableView.separatorColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    self.load_more = YES;
    self.viewType = @"week";
    
    //self.screenName = @"Articles - week";
    
    [self loadArticlesWithSuccess:^(id responseTags) {
        [self.tableView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.mm_drawerController setRightDrawerViewController:nil];
    if(self.mm_drawerController.leftDrawerViewController == nil) {
        // Instantiate and set the left drawer controller.
        UIViewController *leftDrawerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SIDE_DRAWER_CONTROLLER"];
        [self.mm_drawerController setLeftDrawerViewController:leftDrawerViewController];
    }
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Articles"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([Utilities isLandscapeOrientation]) {
        return 80;
    }
    return 95;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(articles == nil) {
        return 0;
    }
    return articles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"article";
    
    ArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[ArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    Article *article = [articles objectAtIndex:indexPath.row];
    cell.lblArticleName.text = article.objectName;
    cell.lblViewsCount.text = [Utilities formatCount:article.objectViews];
    cell.lblVotesCount.text = [Utilities formatCount:article.objectVotes];
    cell.lblPublishedBy.text = article.objectTimeAgo;
    
    NSMutableString *tags = [[NSMutableString alloc] init];
    for(int i = 0; i < article.objectTags.count; i++) {
        NSString *tag = [article.objectTags objectAtIndex:i];
        
        [tags appendString:tag];
        if(i < article.objectTags.count - 1) {
            [tags appendString:@", "];
        }
    }
    if(article.objectTags.count == 0) {
        [tags appendString:@" "];
    }
    
    cell.lblArticleTags.text = tags;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self loadArticleAndRedirectToArticleController:indexPath.row];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(articles.count == 0 || scrollView != self.tableView || !self.load_more) {
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
            
            [self loadArticlesWithSuccess:^(id responseTags) {
                if([responseTags count] > 0) {
                    self.load_more = YES;
                }
                [self.tableView reloadData];
            }];
        }
    }
}

-(void) loadArticlesWithSuccess : (void (^)(id))success
{
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [post setObject:[NSString stringWithFormat:@"%ld", (long) self.page] forKey:@"page"];
    [post setObject:self.viewType forKey:@"view"];
    [JsonRequest postTo:@"/api/GetArticles" onController:self withLoading:TRUE data:post disableUserInput:NO success:^(id responseJson) {
        if(responseJson) {
            NSArray *responseArticles = [Converter toArticles:[responseJson objectForKey:@"articles"]];
            [articles addObjectsFromArray:responseArticles];
            success(responseArticles);
        }
    }];
}

-(void) loadArticleAndRedirectToArticleController:(NSInteger)index {
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [post setObject:[NSString stringWithFormat:@"%ld", (long) (index + 1)] forKey:@"index"];
    [post setObject:self.viewType forKey:@"view"];
    [JsonRequest postTo:@"/api/GetArticle" onController:self withLoading:TRUE data:post disableUserInput:NO success:^(id responseJson) {
        if(responseJson) {
            fullArticles = [Converter toArticles:[responseJson objectForKey:@"articles"]];
            currentIndex = index + 1;
            [self performSegueWithIdentifier:@"articleController" sender:self];
        }
    }];
}

- (void)reloadArtiles
{
    self.load_more = YES;
    [articles removeAllObjects];
    [self loadArticlesWithSuccess:^(id responseArticles) {
        if([responseArticles count] > 0) {
            self.load_more = YES;
        }
        [self.tableView reloadData];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        self.titleBar.title = self.title;
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"articleController"]) {
        
        ArticleController *destinationViewController = (ArticleController *) segue.destinationViewController;
        
        destinationViewController.articles = fullArticles;
        destinationViewController.viewType = self.viewType;
        destinationViewController.currentIndex = currentIndex;
        
        // Instantiate and set the right drawer controller.
        UIViewController *rightDrawerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ARTICLE_RIGHT_DRAWER_CONTROLLER"];
        [self.mm_drawerController setRightDrawerViewController:rightDrawerViewController];
    }
}

@end
