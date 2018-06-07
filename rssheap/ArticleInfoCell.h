//
//  ArticleInfoCell.h
//  rssheap
//
//  Created by Admin on 2/15/15.
//  Copyright (c) 2015 rssheap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblPublishedBy;

@end
