//
//  SearchResult.h
//  BookDiscovery
//
//  Created by Rui Mao on 12/19/18.
//  Copyright © 2018 Rui Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchResult : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* author;
@property (nonatomic, strong) NSString* summary;
@property (nonatomic, strong) UIImage* thumbnailImage;

@end

NS_ASSUME_NONNULL_END
