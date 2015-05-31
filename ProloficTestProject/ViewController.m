//
//  ViewController.m
//  ProloficTestProject
//
//  Created by Ashwin Raghuraman on 5/31/15.
//  Copyright (c) 2015 Ashwin Raghuraman. All rights reserved.
//

#import "ViewController.h"

/**
 A modal object that contains the titleName of the book.
 */
@interface BookItem : NSObject

@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, copy) NSString *authorName;

@end

@implementation BookItem


@end

@interface ViewController ()<NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, strong) NSMutableArray *booksArray;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Books";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Add.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(addBook)];
    
    [self fetchBooksList];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.booksArray count] > 0)
    {
        return [self.booksArray count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"BookCell"];
    }
    
    BookItem *bookItem = [self.booksArray objectAtIndex:indexPath.row];
    cell.textLabel.text = bookItem.titleName;
    cell.detailTextLabel.text = bookItem.authorName;
    
    return cell;
}

#pragma mark - Private Methods

- (void)fetchBooksList
{
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL
                                                          URLWithString:@"http://prolific-interview.herokuapp.com/5565ed6a818b6e0009e6c2e0/books"]];
    
    // Create url connection and fire request
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)addBook
{
    
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to the instance variable you declared
    [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    NSError *jsonParsingError;
    NSArray *booksJsonArray = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                              options:0
                                                                error:&jsonParsingError];
    
    if (!jsonParsingError)
    {
        self.booksArray = [NSMutableArray new];
        
        for (NSDictionary *bookDict in booksJsonArray)
        {
            BookItem *bookItem = [BookItem new];
            bookItem.titleName = [bookDict objectForKey:@"title"];
            bookItem.authorName = [bookDict objectForKey:@"author"];
            [self.booksArray addObject:bookItem];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

@end
