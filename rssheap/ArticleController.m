#import "ArticleController.h"
#import "Article.h"
#import "ArticleViewCell.h"
#import "ArticleInfoCell.h"
#import "ArticleWebController.h"
#import "FontAwesomeKit/FAKFontAwesome.h"
#import "JsonRequest.h"
#import "ArticleTagCell.h"
#import "DWTagList.h"
#import "Converter.h"
#import "Utilities.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "ArticleRightDrawerController.h"
#import "NJKWebViewProgressView.h"
#import <Google/Analytics.h>

@interface ArticleController ()

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation ArticleController

Article *article;
NSUInteger currentIndex;
NSTimer *timer;
NSTimer *loadingTimer;

NJKWebViewProgressView *_progressView;
NJKWebViewProgress *_progressProxy;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self setupRightMenuButton];
    
    if(self.articles == nil || ![Utilities isDeviceOnline]) {
        [self redirectToArticleList];
        return;
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Roboto-Regular" size:16],
      NSFontAttributeName, nil]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    self.carousel.bounceDistance = 0.1f;
    self.carousel.pagingEnabled = YES;
    
    Article *currentArticle = ((Article *) [self.articles objectAtIndex:0]);
    self.barTitle.title = currentArticle.objectName;
    ((ArticleRightDrawerController *) self.mm_drawerController.rightDrawerViewController).article = currentArticle;
    //self.screenName = [@"Article - " stringByAppendingString:currentArticle.objectName];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.scrollView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
    self.webView.frame = self.view.frame;
    
    _progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
    [self.webView setDelegate:_progressProxy];
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;

    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    
    currentIndex = 999;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadWebView) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"articleActions"
                                               object:nil];
}

- (void) receiveNotification:(NSNotification *) notification
{
    NSString *data = [notification object];
    
    if ([data isEqualToString:@"next"]){
        [self.carousel scrollByNumberOfItems:1 duration:0];
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    }
    if ([data isEqualToString:@"prev"]){
        [self.carousel scrollByNumberOfItems:-1 duration:0];
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self.webView stopLoading];
    [self.webView setDelegate:nil];
    [self.webView removeFromSuperview];
    [_progressView setProgress:10];

    _progressProxy = nil;
    [_progressView removeFromSuperview];
    [timer invalidate];
    timer = nil;
}

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:NO];
}

-(void) loadWebView {
    if(currentIndex != self.carousel.currentItemIndex) {
        UIView *currrentView = self.carousel.currentItemView;
        if(currrentView != nil) {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
            
            currentIndex = self.carousel.currentItemIndex;
            Article *article = [self.articles objectAtIndex:currentIndex];
            
            NSURL* nsUrl = [NSURL URLWithString:article.objectUrl];
            NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
            
            //[self.webView removeFromSuperview];
            [self.webView loadRequest:request];
        }
    }
    
    if([self.lblLoading.text isEqualToString:@"Loading Article    "]) {
        [self.lblLoading setText:@"Loading Article .  "];
    } else if([self.lblLoading.text isEqualToString:@"Loading Article .  "]) {
        [self.lblLoading setText:@"Loading Article .. "];
    } else if([self.lblLoading.text isEqualToString:@"Loading Article .. "]) {
        [self.lblLoading setText:@"Loading Article ..."];
    } else if([self.lblLoading.text isEqualToString:@"Loading Article ..."]) {
        [self.lblLoading setText:@"Loading Article    "];
    }
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    UIView *currrentView = self.carousel.currentItemView;
    if(![webView isDescendantOfView:currrentView]) {
        [currrentView addSubview:self.webView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self.mm_drawerController setLeftDrawerViewController:nil];
}

- (void) redirectToArticleList {
    UINavigationController *navigationController = self.navigationController;
    [navigationController popViewControllerAnimated:YES];
}

- (void)setupRightMenuButton {
    MMDrawerBarButtonItem * rightDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(rightDrawerButtonPress:)];
    [self.navigationItem setRightBarButtonItem:rightDrawerButton];
}

- (void)rightDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)orientationChanged:(NSNotification *)notification {
    
    CGRect newFrame = self.view.frame;
    
    for(int i = 0; i < self.carousel.indexesForVisibleItems.count; i++) {
        NSInteger index = [[self.carousel.indexesForVisibleItems objectAtIndex:i] integerValue];
        [self.carousel reloadItemAtIndex:index animated:YES];
    }
    
    [self.webView setFrame:newFrame];
    [self.webView stopLoading];
    [self.webView reload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    if(self.articles == nil) return 0;
    return self.articles.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (view == nil || view.tag != index)
    {
        view = [[UIView alloc] initWithFrame:self.carousel.bounds];
    }
    
    return view;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if([scrollView.panGestureRecognizer translationInView:scrollView.superview].x < 0) {
        [self.carousel scrollByNumberOfItems:1 duration:0.1];
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel;
{
    NSInteger index = carousel.currentItemIndex;
    if(self.articles.count - 1 == index) {
        
        NSInteger nextIndex = index + self.currentIndex + 1;
        [self loadArticlesForIndex:nextIndex withSuccess:^(id articles) {
            
            NSArray *tempArticles = (NSArray *) articles;
            [self.articles addObjectsFromArray:tempArticles];
            
            if(tempArticles.count > 0) {
                
                NSUInteger startIndex = index + 1;
                NSUInteger count = index + tempArticles.count;
                for(NSUInteger i = startIndex; i <= count; i++) {
                    [self.carousel insertItemAtIndex:i animated:YES];
                }
            } else {
                [Utilities showToastOn:self.view withMessage:@"There are no more articles to show in this view"];
            }
            
            return;
        }];
    }
    
    Article *article = (Article *) [self.articles objectAtIndex:index];
    self.barTitle.title = article.objectName;
    ((ArticleRightDrawerController *) self.mm_drawerController.rightDrawerViewController).article = article;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[@"Article - " stringByAppendingString:article.objectName]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (IBAction)voteOnArticleClick:(id)sender {
    UITapGestureRecognizer *recogniser = (UITapGestureRecognizer *)sender;
    
    UIView* view = recogniser.view;
    CGPoint loc = [recogniser locationInView:view];
    
    Article *article = (Article *) [self.articles objectAtIndex:self.carousel.currentItemIndex];
    
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [post setObject:[NSNumber numberWithInteger:article.objectId] forKey:@"id"];
    [JsonRequest postTo:article.objectIVoted ? @"/api/VoteDown" : @"/api/VoteUp" onController:self withLoading:YES data:post disableUserInput:YES success:^(id responseJson) {

        if(!article.objectIDownVoted) {
            if(article.objectIVoted) return;
            
            article.objectIVoted = YES;
            article.objectIDownVoted = NO;
        } else {
            if(article.objectIDownVoted) return;
            article.objectIDownVoted = YES;
            article.objectIVoted = NO;
        }
    }];
}

-(void) loadArticlesForIndex:(NSInteger)index withSuccess:(void (^)(id))success
{
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [post setObject:[NSString stringWithFormat:@"%ld", (long) index] forKey:@"index"];
    [post setObject:self.viewType forKey:@"view"];
    [JsonRequest postTo:@"/api/GetArticle" onController:self withLoading:NO data:post disableUserInput:NO success:^(id responseJson) {
        if(responseJson) {
            NSArray *tempArticles = [Converter toArticles:[responseJson objectForKey:@"articles"]];
            success(tempArticles);
        }
    }];
}

@end
