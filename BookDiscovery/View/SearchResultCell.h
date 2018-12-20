//
//  SearchResultCell.h
//  BookDiscovery
//
//  Created by Rui Mao on 12/19/18.
//  Copyright © 2018 Rui Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@end

NS_ASSUME_NONNULL_END
