#import <UIKit/UIKit.h>
#import "Article.h"
#import "NJKWebViewProgress.h"

@interface ArticleWebController : UIViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>

@property Article *article;
@property IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UINavigationItem *titleBar;
@property (weak, nonatomic) IBOutlet UIView *webViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;


@end
