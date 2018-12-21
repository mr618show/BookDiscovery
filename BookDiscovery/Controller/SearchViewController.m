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
#import "DetailViewController.h"

@interface SearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray<SearchResult *> * searchResults;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
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
    self.hasSearched = NO;
    [self configureTableView:self.tableView];
    [self customizeAppearance];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(0, 0, 24, 24);
    spinner.center = self.view.center;
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    self.activityIndicator = spinner;
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];
}

#pragma Networking Methods

- (NSURL*)iTunesURL: (NSString *) searchText {
    NSString * escapedSearchText = [searchText stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *baseURL = @"https://itunes.apple.com/search?term=%@";
    NSString *urlString = [NSString stringWithFormat:baseURL, escapedSearchText];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

#pragma  - SearchBar Delegate
- (void)performSearchFrom:(NSURL *)url {
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
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update the UI on the main thread
            [self.activityIndicator stopAnimating];
            [self.tableView reloadData];
        });
    }];
    [task resume];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text != nil) {
        [searchBar resignFirstResponder];
        [self.activityIndicator startAnimating];
        self.hasSearched = YES;
        NSURL *url = [self iTunesURL:self.searchBar.text];
        [self performSearchFrom:url];
    }
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTop;
}

#pragma  - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.hasSearched == NO) {
        return 0;
    } else if (self.searchResults.count == 0) {
        return 1;
    } else {
      return self.searchResults.count;
    }
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
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: searchResult.imageSmallURL]];
        cell.thumbnailImage.image = [UIImage imageWithData: imageData];
        return cell;
    }
}

#pragma mark- tableView Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    DetailViewController *detailViewController = (DetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailViewController.currentSearchResult = self.searchResults[indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchResults.count == 0){
        return nil;
    } else {
        return indexPath;
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

-(NSMutableArray <SearchResult *> *) parse: (NSDictionary *) dictionary {
    NSArray * array = dictionary[@"results"];
    self.searchResults = NSMutableArray.new;
    for (NSDictionary * resultDict in array) {
        if ([resultDict[@"wrapperType"] isEqualToString: @"audiobook"]){
            SearchResult * newResult = [self parseAudioBook:resultDict];
            [self.searchResults addObject:newResult];
        }
        if ([resultDict[@"wrapperType"] isEqualToString: @"track"] && [resultDict[@"kind"] isEqualToString:@"ebook"]){
            SearchResult * newResult = [self parseEBook:resultDict];
            [self.searchResults addObject:newResult];
        }
    }
    return self.searchResults;
}

-(SearchResult *)parseAudioBook: (NSDictionary *) dictionary {
    SearchResult *searchResult = SearchResult.new;
    searchResult.title = dictionary[@"collectionName"];
    searchResult.author = dictionary[@"artistName"];
    searchResult.imageSmallURL = dictionary[@"artworkUrl60"];
    searchResult.imageLargeURL = dictionary[@"artworkUrl100"];
    searchResult.storeURL = dictionary[@"collectionViewUrl"];
    searchResult.price = dictionary[@"collectionPrice"];
    searchResult.currency = dictionary[@"currency"];
    searchResult.summary = dictionary[@"description"];
    return searchResult;
}

-(SearchResult *)parseEBook: (NSDictionary *) dictionary {
    SearchResult *searchResult = SearchResult.new;
    searchResult.title = dictionary[@"trackName"];
    searchResult.author = dictionary[@"artistName"];
    searchResult.imageSmallURL = dictionary[@"artworkUrl60"];
    searchResult.imageLargeURL = dictionary[@"artworkUrl100"];
    searchResult.storeURL = dictionary[@"trackViewUrl"];
    searchResult.price = dictionary[@"price"];
    searchResult.currency = dictionary[@"currency"];
    return searchResult;
}

-(void) customizeAppearance {
    UIColor *barTintColor = [UIColor colorWithRed:20/255 green:160/255 blue:160/255 alpha:1];
    [self.navigationController.navigationBar setBarTintColor:barTintColor];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.searchBar setTintColor: UIColor.whiteColor];
    [self.searchBar setPlaceholder: @"Book name, author or keyword"];
    self.navigationItem.titleView = self.searchBar;
}

@end


