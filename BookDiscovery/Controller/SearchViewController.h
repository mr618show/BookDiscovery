//
//  ViewController.h
//  BookDiscovery
//
//  Created by Rui Mao on 12/19/18.
//  Copyright © 2018 Rui Mao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

