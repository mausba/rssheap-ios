//
//  FeedCell.h
//  rssheap
//
//  Created by Admin on 1/30/15.
//  Copyright (c) 2015 rssheap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblFeedName;
@property (weak, nonatomic) IBOutlet UIImageView *favicon;

@end
