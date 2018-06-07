//
//  ArticleTagCell.h
//  rssheap
//
//  Created by Admin on 2/17/15.
//  Copyright (c) 2015 rssheap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleTagCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblVoteUp;
@property (weak, nonatomic) IBOutlet UILabel *lblVoteCount;
@property (weak, nonatomic) IBOutlet UILabel *lblVoteDown;

@end
