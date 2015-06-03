//
//  ViewController.m
//  ProloficTestProject
//
//  Created by Ashwin Raghuraman on 5/31/15.
//  Copyright (c) 2015 Ashwin Raghuraman. All rights reserved.
//

#import "BooksViewController.h"
#import "BookDetails.h"
#import "BookDetailsViewController.h"
#import "AddBookViewController.h"
#import "MBProgressHUD.h"

@interface BooksViewController ()<NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, strong) NSMutableArray *booksArray;

@property (nonatomic, strong) BookDetails *currentlySelectedBook;

@property (nonatomic, copy) NSString *baseURL;

@property (nonatomic) NSInteger responseStatusCode;

@end

@implementation BooksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.baseURL = @"http://prolific-interview.herokuapp.com/5565ed6a818b6e0009e6c2e0";
    
    self.title = @"Books";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Book"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(addBook)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear Books"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(clearAllButtonPressed)];
}

- (void)viewDidAppear:(BOOL)animated
{
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
    
    if ([self.booksArray count] > 0)
    {
        BookDetails *bookDetailsItem = [self.booksArray objectAtIndex:indexPath.row];
        cell.textLabel.text = bookDetailsItem.titleName;
        cell.detailTextLabel.text = bookDetailsItem.authorName;
    }
    else
    {
        cell.textLabel.text = @"No Books Currently Listed";
    }
    
    return cell;
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentlySelectedBook = [self.booksArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showBookDetails" sender:self];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookDetails *bookDetailItem = [self.booksArray objectAtIndex:indexPath.row];
    
    // Create the request
    NSString *requestURL = [self.baseURL stringByAppendingString:bookDetailItem.url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:requestURL]];
    [request setHTTPMethod:@"DELETE"];
    
    // Create url connection and fire request
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.booksArray removeObjectAtIndex:indexPath.row];
        
        // Handling the case when the deleted row is the last row in the section.
        if (indexPath.row == 0)
        {
            [tableView reloadData];
            return;
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
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

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    self.responseData = [[NSMutableData alloc] init];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    self.responseStatusCode = httpResponse.statusCode;
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
    
    if (self.responseStatusCode == 200)
    {
        NSString *urlString = [[[connection currentRequest] URL] absoluteString];
        NSArray *parts = [urlString componentsSeparatedByString:@"/"];
        
        // This is for handling the "Delete all Books" request.
        // we get the request string and check if we had made the "clean" request
        if ([[parts lastObject] isEqualToString:@"clean"])
        {
            self.booksArray = [NSMutableArray new];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            return;
        }
        
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
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        else
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            // Add a debug logger to say there was a JSON parsing error, which would help with debugging.
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // The request has failed for some reason!
    // Check the error var
    self.booksArray = nil;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    if ([error code] == NSURLErrorNotConnectedToInternet)
    {
        [self showAlertViewWithMessage:@"Please ensure internet connection is available"];
    }
    else
    {
        [self showAlertViewWithMessage:@"Server not responding"];
    }
    
}

#pragma mark - Private Methods

- (void)fetchBooksList
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Fetching Book Titles";
    
    // Create the request.
    NSString *requestURL = [self.baseURL stringByAppendingString:@"/books"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL
                                                          URLWithString:requestURL]];
    
    // Create url connection and fire request
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)addBook
{
    AddBookViewController *addBookController = [[AddBookViewController alloc] init];
    [self.navigationController pushViewController:addBookController animated:YES];
}

- (void)clearAllButtonPressed
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"Are you sure you want to delete All Books?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self clearAllBooks];
                                                          }];
    [alert addAction:defaultAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)clearAllBooks
{
    // Create the request
    NSString *requestURL = [self.baseURL stringByAppendingString:@"/clean"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:requestURL]];
    [request setHTTPMethod:@"DELETE"];
    
    // Create url connection and fire request
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
