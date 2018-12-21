//
//  DetailViewController.h
//  BookDiscovery
//
//  Created by Rui Mao on 12/20/18.
//  Copyright © 2018 Rui Mao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *titileLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UIView *summaryContainerView;
@property (strong, nonatomic) SearchResult *currentSearchResult;

@end

NS_ASSUME_NONNULL_END
