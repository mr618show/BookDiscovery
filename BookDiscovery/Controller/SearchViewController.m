//
//  ViewController.m
//  BookDiscovery
//
//  Created by Rui Mao on 12/19/18.
//  Copyright © 2018 Rui Mao. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResult.h"
#import "SearchResultCell.h"

@interface SearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray<SearchResult *> * searchResults;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    UINib *nib = [UINib nibWithNibName:@"SearchResultCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"SearchResultCell"];
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchResults = NSMutableArray.new;
    SearchResult * searchResult = SearchResult.new;
    searchResult.title = self.searchBar.text;
    [self.searchResults addObject: searchResult];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cellIndetifier = @"SearchResultCell";
    SearchResultCell * cell = [self.tableView dequeueReusableCellWithIdentifier:cellIndetifier];
    if (self.searchResults.count == 0) {
        cell.titleLabel.text = @"Nothing found";
        cell.authorLabel.text = @"";
    } else {
        SearchResult * searchResult = _searchResults[indexPath.row];
        cell.titleLabel.text = searchResult.title;
        cell.authorLabel.text = searchResult.author;
    }
    return cell;
}

@end


