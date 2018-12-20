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
#import "NotFoundCell.h"

@interface SearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray<SearchResult *> * searchResults;
@property (assign, nonatomic) BOOL hasSearched;
@end

@implementation SearchViewController

- (void)configureTableView: (UITableView *_Nonnull) tableView {
    NSBundle *thisBundle = [NSBundle bundleForClass: [self class]];
    NSString *searchResultCell = NSStringFromClass([SearchResultCell class]);
    NSString *notFoundCell = NSStringFromClass([NotFoundCell class]);
    UINib *searchResultCellNib = [UINib nibWithNibName:searchResultCell bundle:thisBundle];
    [self.tableView registerNib:searchResultCellNib forCellReuseIdentifier:searchResultCell];
     UINib *notFoundCellNib = [UINib nibWithNibName:notFoundCell bundle:thisBundle];
    [self.tableView registerNib:notFoundCellNib forCellReuseIdentifier:notFoundCell];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    [self configureTableView:self.tableView];
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}
#pragma Networking Methods

- (NSURL*)iTunesURL: (NSString *) searchText {
    NSString * escapedSearchText = [searchText stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *baseURL = @"https://itunes.apple.com/search?term=%@";
    NSString *urlString = [NSString stringWithFormat:baseURL, escapedSearchText];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

//- (NSString *) performStoreRequestFrom: (NSURL *) url {
//    
//    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        return [[NSString alloc] initWithData: location encoding:NSUTF8StringEncoding];
//    }];
//    [task resume];
//}

#pragma  - SearchBar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text != nil) {
        [searchBar resignFirstResponder];
        self.hasSearched = YES;
        NSURL *url = [self iTunesURL:self.searchBar.text];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [self showAlert];
                return;
            }
            
            if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
                NSInteger statusCode = [(NSHTTPURLResponse *) response statusCode];
                if (statusCode != 200) {
                    [self showAlert];
                    return;
                }
            }
            NSString *jsonString = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            NSData *objectData = [jsonString dataUsingEncoding: NSUTF8StringEncoding];
            NSError *jsonError;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:objectData
                                                                           options:NSJSONReadingMutableContainers
                                                                             error: &jsonError];
            [self parse: jsonDictionary];
            NSLog(@"jsonDict: %@", jsonDictionary);
        }];
        [task resume];
        
        [self.tableView reloadData];
    }


}

#pragma  - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *searchResultCell = NSStringFromClass([SearchResultCell class]);
    NSString *notFoundCell = NSStringFromClass([NotFoundCell class]);
    if (self.searchResults.count == 0) {
        return [self.tableView dequeueReusableCellWithIdentifier:notFoundCell forIndexPath:indexPath];
    } else {
        SearchResultCell * cell = [self.tableView dequeueReusableCellWithIdentifier:searchResultCell];
        SearchResult * searchResult = _searchResults[indexPath.row];
        cell.titleLabel.text = searchResult.title;
        cell.authorLabel.text = searchResult.author;
        return cell;
    }
}

#pragma Private Method

-(void) showAlert{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Whoops..."
                                                                   message:@"There was an error reading from the iTunes Store. Please try again."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) parse: (NSDictionary *) dictionary {
    NSArray * array = dictionary[@"results"];
    for (NSDictionary * resultDict in array) {
        NSString * wrapperType = resultDict[@"wrapperType"];
        NSString * kind = resultDict[@"kind"];
        NSLog(@"wrapperType: %@, kind: %@", wrapperType, kind);
    }
}

@end


