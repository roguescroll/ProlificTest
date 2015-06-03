//
//  AddBookViewController.m
//  ProloficTestProject
//
//  Created by Ashwin Raghuraman on 5/31/15.
//  Copyright (c) 2015 Ashwin Raghuraman. All rights reserved.
//

#import "AddBookViewController.h"
#import "MBProgressHUD.h"

@interface AddBookViewController ()

@property (nonatomic, weak) IBOutlet UITextField *titleField;
@property (nonatomic, weak) IBOutlet UITextField *authorField;
@property (nonatomic, weak) IBOutlet UITextField *publisherField;
@property (nonatomic, weak) IBOutlet UITextField *categoriesField;

@property (nonatomic, strong) NSMutableData *responseData;

@end

@implementation AddBookViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Add Book";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonPressed)];
}

#pragma mark - IBAction

- (IBAction)addBook:(id)sender
{
    if ([self fieldsValid])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Adding Book";
        
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL:[NSURL URLWithString:@"http://prolific-interview.herokuapp.com/5565ed6a818b6e0009e6c2e0/books/"]];
        
        NSDictionary *requestData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.titleField.text, @"title",
                                     self.authorField.text, @"author",
                                     self.publisherField.text, @"publisher",
                                     self.categoriesField.text, @"categories",
                                     nil];
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:postData];
        (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
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
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
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

- (void)doneButtonPressed
{
    if ([self fieldsNotEmpty])
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:@"Are you sure you want to close the Add books view?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self.navigationController popViewControllerAnimated:YES];
                                                              }];
        [alert addAction:defaultAction];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                             }];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)fieldsValid
{
    if ([self.titleField.text length] < 1)
    {
        [self showAlertViewWithMessage:@"Please enter the title"];
        return NO;
    }
    else if ([self.authorField.text length] < 1)
    {
        [self showAlertViewWithMessage:@"Please enter the author name"];
        return NO;
    }
    return YES;
}

// this is for checking if the user had entered any information before hitting the Done button
- (BOOL)fieldsNotEmpty
{
    return (([self.titleField.text length] > 0)
            || ([self.authorField.text length] > 0)
            || ([self.publisherField.text length] > 0)
            || ([self.categoriesField.text length] > 0));
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
