//
//  BookDetailsViewController.m
//  ProloficTestProject
//
//  Created by Ashwin Raghuraman on 5/31/15.
//  Copyright (c) 2015 Ashwin Raghuraman. All rights reserved.
//

#import "BookDetailsViewController.h"
#import "BookDetails.h"
#import "MBProgressHUD.h"

@interface BookDetailsViewController ()<NSURLConnectionDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *publisherLabel;
@property (nonatomic, weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastCheckedoutLabel;

@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, strong) BookDetails *bookDetails;

@end

@implementation BookDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Detail";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(shareBook)];
    
    [self retrieveBookDetails];
    
}

#pragma mark - IBAction

- (IBAction)checkout:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"Please Enter your name"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"Name";
     }];
    
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              UITextField *nameField = alert.textFields[0];
                                                              [self checkoutBookWithName:nameField.text];
                                                          }];
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
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
    NSDictionary *bookDetailDict = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                              options:0
                                                                error:&jsonParsingError];
    
    if (!jsonParsingError && bookDetailDict)
    {
        // we parse the response and update the result into the BookDetails Object.
        
        self.bookDetails = [BookDetails new];
        
        self.bookDetails.titleName = [bookDetailDict objectForKey:@"title"];
        self.bookDetails.authorName = [bookDetailDict objectForKey:@"author"];
        
        NSString *publisherString = [bookDetailDict objectForKey:@"publisher"];
        if (publisherString && publisherString != (id)[NSNull null])
        {
            self.bookDetails.publisher = publisherString;
        }
        else
        {
            self.bookDetails.publisher = @"Unknown";
        }
        
        NSString *tagsString = [bookDetailDict objectForKey:@"categories"];
        if (tagsString && tagsString != (id)[NSNull null])
        {
            self.bookDetails.categories = tagsString;
        }
        else
        {
            self.bookDetails.categories = @"-";
        }
        
        NSString *lastCheckedOutByString = [bookDetailDict objectForKey:@"lastCheckedOutBy"];
        if (lastCheckedOutByString && lastCheckedOutByString != (id)[NSNull null])
        {
            self.bookDetails.lastCheckedOutBy = lastCheckedOutByString;
            
        }
        else
        {
            self.bookDetails.lastCheckedOutBy = @"";
        }
        
        NSString *lastCheckedOutString = [bookDetailDict objectForKey:@"lastCheckedOut"];
        if (lastCheckedOutString && lastCheckedOutString != (id)[NSNull null])
        {
            self.bookDetails.lastCheckedOut = lastCheckedOutString;
            
        }
        else
        {
            self.bookDetails.lastCheckedOut = @"";
        }
        
        [self setUpBookDetails];
    }
    
    else
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        // log a debug log
        
        [self showAlertViewWithMessage:@"Unable to display book details."];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // The request has failed for some reason!
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
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

- (void)retrieveBookDetails
{
    // Create the request.
    
    NSString *baseURL = @"http://prolific-interview.herokuapp.com/5565ed6a818b6e0009e6c2e0";
    NSString *requestString = [baseURL stringByAppendingString:self.selectedBookDetailsURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    
    // Create url connection and fire request
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)shareBook
{
    NSString *textToShare = @"I would like to share this book details with you!";
    NSArray *objectsToShare = @[textToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare
                                                                             applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)setUpBookDetails
{
    self.titleLabel.text = self.bookDetails.titleName;
    self.authorLabel.text = self.bookDetails.authorName;
    self.publisherLabel.text = [NSString stringWithFormat:@"Publisher: %@", self.bookDetails.publisher];
    self.tagsLabel.text = [NSString stringWithFormat:@"Tags: %@", self.bookDetails.categories];
    
    if ([self.bookDetails.lastCheckedOut length] > 0 && [self.bookDetails.lastCheckedOutBy length] > 0)
    {
        NSString *combinedLastCheckoutString = [NSString stringWithFormat:@"%@ @ %@", self.bookDetails.lastCheckedOutBy,
                                                self.bookDetails.lastCheckedOut];
        self.lastCheckedoutLabel.text = [NSString stringWithFormat:@"Last Checked Out : %@", combinedLastCheckoutString];
    }
    else
    {
        self.lastCheckedoutLabel.text = @"Last Checked Out: ";
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)checkoutBookWithName:(NSString *)name
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Checking Out Book";
    
    NSString *baseURL = @"http://prolific-interview.herokuapp.com/5565ed6a818b6e0009e6c2e0";
    NSString *requestString = [baseURL stringByAppendingString:self.selectedBookDetailsURL];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:requestString]];
    
    NSDictionary *requestData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 name, @"lastCheckedOutBy",
                                 nil];
    NSError *error;
    NSData *putData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:putData];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)showAlertViewWithMessage:(NSString *)message
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                          }];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
