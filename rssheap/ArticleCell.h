//
//  ArticleCell.h
//  rssheap
//
//  Created by Admin on 2/8/15.
//  Copyright (c) 2015 rssheap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblVotesCount;
@property (weak, nonatomic) IBOutlet UILabel *lblViewsCount;

@property (weak, nonatomic) IBOutlet UILabel *lblArticleName;
@property (weak, nonatomic) IBOutlet UILabel *lblArticleTags;
@property (weak, nonatomic) IBOutlet UILabel *lblPublishedBy;

@end
