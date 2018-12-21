//
//  DetailViewController.m
//  BookDiscovery
//
//  Created by Rui Mao on 12/20/18.
//  Copyright © 2018 Rui Mao. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titileLabel.text = self.currentSearchResult.title;
    self.authorLabel.text = self.currentSearchResult.author;
    self.priceLabel.text = [self.currentSearchResult.price stringValue];
    self.summaryLabel.text = [self stringByStrippingHTML: self.currentSearchResult.summary];
    self.currencyLabel.text = self.currentSearchResult.currency;
    self.profileImageView.image = [self downloadImageFromURL: self.currentSearchResult.imageSmallURL];
    self.backgroundImageView.image = [self downloadImageFromURL:self.currentSearchResult.imageLargeURL];
    self.summaryContainerView.layer.cornerRadius = 5.0;
    self.summaryContainerView.layer.masksToBounds = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma private method

-(UIImage *) downloadImageFromURL :(NSString *)imageUrl{
    
    NSURL  *url = [NSURL URLWithString:imageUrl];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if (urlData){
        NSLog(@"Downloading started...");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"dwnld_image.png"];
        NSLog(@"FILE : %@",filePath);
        [urlData writeToFile:filePath atomically:YES];
        return [UIImage imageWithContentsOfFile:filePath];
    }
    return nil;
}

-(NSString *) stringByStrippingHTML: (NSString *) string {
    NSRange range;
    NSString *outputString = [string copy];
    while ((range = [outputString rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        outputString = [outputString stringByReplacingCharactersInRange:range withString:@""];
    return outputString;
}

@end
