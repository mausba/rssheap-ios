#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "DWTagList.h"
#import "NJKWebViewProgress.h"
#import <WebKit/WebKit.h>

@interface ArticleController : UIViewController<iCarouselDataSource, iCarouselDelegate,UIScrollViewDelegate, NJKWebViewProgressDelegate, UIWebViewDelegate>


@property (weak, nonatomic) IBOutlet iCarousel *carousel;

@property (weak, nonatomic) IBOutlet UINavigationItem *barTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblLoading;

@property (nonatomic) CGFloat lastContentOffset;
@property UIWebView *webView;

@property NSString *viewType;
@property NSInteger currentIndex;
@property NSMutableArray *articles;

@end
