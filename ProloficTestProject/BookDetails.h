//
//  BookDetails.h
//  ProloficTestProject
//
//  Created by Ashwin Raghuraman on 5/31/15.
//  Copyright (c) 2015 Ashwin Raghuraman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookDetails : NSObject

@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *lastCheckedOut;
@property (nonatomic, copy) NSString *lastCheckedOutBy;
@property (nonatomic, copy) NSString *publisher;
@property (nonatomic, copy) NSString *url;

@end
