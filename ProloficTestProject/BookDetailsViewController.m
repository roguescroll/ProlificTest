//
//  BookDetailsViewController.m
//  ProloficTestProject
//
//  Created by Ashwin Raghuraman on 5/31/15.
//  Copyright (c) 2015 Ashwin Raghuraman. All rights reserved.
//

#import "BookDetailsViewController.h"
#import "BookDetails.h"

@interface BookDetailsViewController ()<NSURLConnectionDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *publisherLabel;
@property (nonatomic, weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastCheckedoutLabel;

@property (nonatomic, strong) NSMutableData *responseData;

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
        self.titleLabel.text = [bookDetailDict objectForKey:@"title"];
        self.authorLabel.text = [bookDetailDict objectForKey:@"author"];
        
        NSString *publisherString = [bookDetailDict objectForKey:@"publisher"];
        if (publisherString && publisherString != (id)[NSNull null])
        {
            self.publisherLabel.text = [NSString stringWithFormat:@"Publisher: %@", publisherString];
        }
        else
        {
            self.publisherLabel.text = [NSString stringWithFormat:@"Publisher: Unknown"];
        }
        
        NSString *tagsString = [bookDetailDict objectForKey:@"categories"];
        if (tagsString && tagsString != (id)[NSNull null])
        {
            self.tagsLabel.text = [NSString stringWithFormat:@"Tags: %@", tagsString];
        }
        else
        {
            self.tagsLabel.text = @"Tags: -";
        }
        
        NSString *lastCheckedOutByString = [bookDetailDict objectForKey:@"lastCheckedOutBy"];
        if (lastCheckedOutByString && lastCheckedOutByString != (id)[NSNull null])
        {
            NSString *combinedLastCheckoutString = [NSString stringWithFormat:@"%@ @ %@", [bookDetailDict objectForKey:@"lastCheckedOutBy"], [bookDetailDict objectForKey:@"lastCheckedOut"]];
            
            self.lastCheckedoutLabel.text = [NSString stringWithFormat:@"Last Checked Out : %@", combinedLastCheckoutString];
        }
        else
        {
            self.lastCheckedoutLabel.text = @"Last Checked Out: -";
        }
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

@end
