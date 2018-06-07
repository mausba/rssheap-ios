#import "ArticleRightDrawerController.h"
#import "ArticleActionDrawerCell.h"
#import "JsonRequest.h"
#import "Utilities.h"
#import <TwitterKit/TwitterKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "PocketAPI.h"

@interface ArticleRightDrawerController ()

@end

@implementation ArticleRightDrawerController

NSMutableArray *articleActions;

- (void)viewDidLoad {
    [super viewDidLoad];
    articleActions = [[NSMutableArray alloc] init];
    self.table.separatorColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
}

- (NSMutableArray *) getActionsForArticle:(Article *)article {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [result addObject:@"Next Article"];
    [result addObject:@"Previous Article"];
    if(self.article.objectIVoted) {
        [result addObject:@"Vote Down"];
    } else if(article.objectIDownVoted) {
        [result addObject:@"Vote Up"];
    } else {
        [result addObject:@"Vote Up"];
        [result addObject:@"Vote Down"];
    }
    
    if(self.article.objectIsMyFavorite) {
        [result addObject:@"Remove from favorites"];
    } else {
        [result addObject:@"Add to favorites"];
    }

    [result addObject:@"Flag as not related"];
    [result addObject:@"Twitter"];
    [result addObject:@"Facebook"];
    [result addObject:@"Google+"];
    [result addObject:@"Pocket"];
    [result addObject:@"Share"];
    return result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(articleActions.count == 0 && self.article != nil) {
        articleActions = [self getActionsForArticle:self.article];
    }
    return articleActions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"actionArticleCell";
    
    ArticleActionDrawerCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[ArticleActionDrawerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSString *action = [articleActions objectAtIndex:indexPath.row];
    cell.lblAction.text = action;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *action = [articleActions objectAtIndex:indexPath.row];
    ArticleActionDrawerCell *cell = (ArticleActionDrawerCell *) [tableView cellForRowAtIndexPath:indexPath];
    
    NSMutableDictionary *post = [[NSMutableDictionary alloc] init];
    [post setObject:[NSNumber numberWithInteger:self.article.objectId] forKey:@"id"];
    
    if([action isEqualToString:@"Next Article"]) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"articleActions"
         object:@"next"];
    }
    if([action isEqualToString:@"Previous Article"]) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"articleActions"
         object:@"prev"];
    }
    if([action isEqualToString:@"Vote Up"]) {
        
        [JsonRequest postTo:@"/api/VoteUp" onController:self withLoading:NO data:post disableUserInput:YES success:^(id responseJson) {
            self.article.objectIVoted = YES;
            self.article.objectIDownVoted = NO;
            [self reloadTable];
        }];
    }
    if([action isEqualToString:@"Vote Down"]) {
        
        [JsonRequest postTo:@"/api/VoteDown" onController:self withLoading:NO data:post disableUserInput:YES success:^(id responseJson) {
            self.article.objectIVoted = NO;
            self.article.objectIDownVoted = YES;
            [self reloadTable];
        }];
    }
    if([action isEqualToString:@"Add to favorites"]) {
        
        [JsonRequest postTo:@"/api/AddToFavorites" onController:self withLoading:NO data:post disableUserInput:YES success:^(id responseJson) {
            self.article.objectIsMyFavorite = YES;
            [self reloadTable];
        }];

    }
    if([action isEqualToString:@"Remove from favorites"]) {
        
        [JsonRequest postTo:@"/api/RemoveFromFavorites" onController:self withLoading:NO data:post disableUserInput:YES success:^(id responseJson) {
            self.article.objectIsMyFavorite = NO;
            [self reloadTable];
        }];
    }
    if([action isEqualToString:@"Flag as not related"]) {
        
        [JsonRequest postTo:@"/api/Flag" onController:self withLoading:NO data:post disableUserInput:YES success:^(id responseJson) {
            cell.lblAction.text = @"Flagged";
        }];
    }
    if([action isEqualToString:@"Twitter"]) {
        
        cell.lblAction.text = @"Please wait";
        TWTRComposer *composer = [[TWTRComposer alloc] init];
        
        [composer setText:self.article.objectTweet];
        [composer showFromViewController:self completion:^(TWTRComposerResult result) {
            if (result != TWTRComposerResultCancelled) {
                [Utilities showToastOn:self.view withMessage:@"Twitted!"];
            }
            cell.lblAction.text = @"Twitter";
        }];
    }
    if([action isEqualToString:@"Facebook"]) {
        
        cell.lblAction.text = @"Please wait";
        
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:[@"http://rssheap.com/a/" stringByAppendingString:self.article.objectShortUrl]];
        [FBSDKShareDialog showFromViewController:self
                                     withContent:content
                                        delegate:nil];
    }
    if([action isEqualToString:@"Google+"]) {
        
        cell.lblAction.text = @"Please wait";
        
        NSString *strUrl = [@"https://plus.google.com/share?url=" stringByAppendingString:[@"http://rssheap.com/a/" stringByAppendingString:self.article.objectShortUrl]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
        
        //GPPSignIn *signIn = [GPPSignIn sharedInstance];
        //signIn.shouldFetchGooglePlusUser = YES;
        //signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
        //signIn.shouldFetchGoogleUserID = YES;
        //signIn.clientID = @"438309243479-h8tnq3c3q78duo7i9tg4jpa26m17c87a.apps.googleusercontent.com";
        
        // Uncomment one of these two statements for the scope you chose in the previous step
        //signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
        //signIn.scopes = @[ @"profile", @"https://www.googleapis.com/auth/plus.login"];            // "profile" scope
        
        // Optional: declare signIn.actions, see "app activities"
        //signIn.delegate = self;
        //[[GPPSignIn sharedInstance] authenticate];
        cell.lblAction.text = @"Google+";
    }
    if([action isEqualToString:@"Pocket"]) {
        
        cell.lblAction.text = @"Please wait";
        NSURL *url = [NSURL URLWithString:[@"http://rssheap.com/a/" stringByAppendingString:self.article.objectShortUrl]];
        [[PocketAPI sharedAPI] saveURL:url handler: ^(PocketAPI *API, NSURL *URL, NSError *error){
            if(!error){
                [Utilities showToastOn:self.view withMessage:@"Saved on Pocket"];
            }
            cell.lblAction.text = @"Pocket";
        }];
    }
    if([action isEqualToString:@"Share"]) {
        
        NSString *shareText = [self.article.objectName stringByAppendingString:@" via @rssheap"];
        NSURL *url = [NSURL URLWithString:[@"http://rssheap.com/a/" stringByAppendingString:self.article.objectShortUrl]];
        
        UIActivityViewController *controller =
        [[UIActivityViewController alloc]
         initWithActivityItems:@[shareText, url]
         applicationActivities:nil];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

//- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
//                   error: (NSError *) error {
//    if(error == nil && auth != nil) {
//        id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
        
        // This line will fill out the title, description, and thumbnail from
        // the URL that you are sharing and includes a link to that URL.
//        [shareBuilder setURLToShare:[NSURL URLWithString:[@"http://rssheap.com/a/" stringByAppendingString:self.article.objectShortUrl]]];
        
//        [shareBuilder open];
//    }
//}

-(void) reloadTable {
    articleActions = [self getActionsForArticle:self.article];
    [self.table reloadData];
}


@end
