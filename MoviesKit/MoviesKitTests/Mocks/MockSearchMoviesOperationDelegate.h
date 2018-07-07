//
//  MockSearchMoviesOperationDelegate.h
//  MoviesKitTests
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchMoviesOperation.h"

@interface MockSearchMoviesOperationDelegate : NSObject <SearchMoviesOperationDelegate>

//-(void)onSuccessWithData:(NSData*) responseData andQueryString:(NSString*)queryString andYear:(NSString*)year;
//-(void)onFailureDueToNetworkError;
//-(void)onFailureDueToInvalidResponse;
//-(void)onFailureDueToInvalidAPIKey;

@property(nonatomic, assign) NSData *responseData;
@property(nonatomic, assign) NSString *queryString;
@property(nonatomic, assign) NSString *year;
@property(nonatomic, assign) Boolean onSuccessWithDataWasCalled;
@property(nonatomic, assign) Boolean onFailureDueToNetworkErrorWasCalled;
@property(nonatomic, assign) Boolean onFailureDueToInvalidResponseWasCalled;
@property(nonatomic, assign) Boolean onFailureDueToInvalidAPIKeyWasCalled;

@end
