#import "ArticleWebController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "Utilities.h"
#import <Google/Analytics.h>

@interface ArticleWebController ()

@end

@implementation ArticleWebController

NJKWebViewProgressView *_progressView;
NJKWebViewProgress *_progressProxy;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.webViewContainer.bounds];
    [self.webViewContainer addSubview:self.webView];
    [self.webViewContainer addSubview:self.btnNext];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Roboto-Regular" size:16],
      NSFontAttributeName, nil]];
    
    [self setupRightMenuButton];
    
    if(self.article == nil || ![Utilities isDeviceOnline]) {
        [self redirectToArticleList];
        return;
    }
    
    self.titleBar.title = self.article.objectName;
    
    NSURL* nsUrl = [NSURL URLWithString:self.article.objectUrl];
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    _progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
    self.webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    self.webView.autoresizesSubviews = true;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    [self.webView loadRequest:request];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.mm_drawerController setLeftDrawerViewController:nil];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[@"Article Web - " stringByAppendingString:self.article.objectName]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)orientationChanged:(NSNotification *)notification{
    [self redirectToArticleList];
}

- (void) redirectToArticleList {
    UINavigationController *navigationController = self.navigationController;
    [navigationController popViewControllerAnimated:NO];
    [navigationController popViewControllerAnimated:YES];
}

- (void)setupRightMenuButton {
    MMDrawerBarButtonItem * rightDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(rightDrawerButtonPress:)];
    [self.navigationItem setRightBarButtonItem:rightDrawerButton];
}

- (void)rightDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
