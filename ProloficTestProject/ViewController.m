//
//  ViewController.m
//  ProloficTestProject
//
//  Created by Ashwin Raghuraman on 5/31/15.
//  Copyright (c) 2015 Ashwin Raghuraman. All rights reserved.
//

#import "ViewController.h"
#import "BookDetails.h"
#import "BookDetailsViewController.h"

@interface ViewController ()<NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, strong) NSMutableArray *booksArray;

@property (nonatomic, strong) BookDetails *currentlySelectedBook;

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
    
    BookDetails *bookDetailsItem = [self.booksArray objectAtIndex:indexPath.row];
    cell.textLabel.text = bookDetailsItem.titleName;
    cell.detailTextLabel.text = bookDetailsItem.authorName;
    
    return cell;
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentlySelectedBook = [self.booksArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showBookDetails" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"showBookDetails"])
    {
        BookDetailsViewController *bookDetailsController = [segue destinationViewController];
        bookDetailsController.selectedBookDetailsURL = self.currentlySelectedBook.url;
    }
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
            BookDetails *bookDetailsItem = [BookDetails new];
            bookDetailsItem.titleName = [bookDict objectForKey:@"title"];
            bookDetailsItem.authorName = [bookDict objectForKey:@"author"];
            bookDetailsItem.lastCheckedOut = [bookDict objectForKey:@"lastCheckedOut"];
            bookDetailsItem.lastCheckedOutBy = [bookDict objectForKey:@"lastCheckedOutBy"];
            bookDetailsItem.publisher = [bookDict objectForKey:@"publisher"];
            bookDetailsItem.url = [bookDict objectForKey:@"url"];
            bookDetailsItem.categories = [bookDict objectForKey:@"categories"];
            
            [self.booksArray addObject:bookDetailsItem];
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
