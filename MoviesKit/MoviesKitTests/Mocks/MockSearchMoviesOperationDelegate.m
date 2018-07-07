//
//  MockSearchMoviesOperationDelegate.m
//  MoviesKitTests
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import "MockSearchMoviesOperationDelegate.h"

@implementation MockSearchMoviesOperationDelegate

-(id) init {
    self = [super init];
    if (self) {
        self.onSuccessWithDataWasCalled = NO;
        self.onFailureDueToNetworkErrorWasCalled = NO;
        self.onFailureDueToInvalidResponseWasCalled = NO;
        self.onFailureDueToInvalidAPIKeyWasCalled = NO;
    }
    return self;
}

-(void)onSuccessWithData:(NSData*) responseData andQueryString:(NSString*)queryString andYear:(NSString*)year {
    self.onSuccessWithDataWasCalled = YES;
    self.responseData = responseData;
    self.queryString = queryString;
    self.year = year;
}

-(void)onFailureDueToNetworkError {
    self.onFailureDueToNetworkErrorWasCalled = YES;
}

-(void)onFailureDueToInvalidResponse {
    self.onFailureDueToInvalidResponseWasCalled = YES;
}

-(void)onFailureDueToInvalidAPIKey {
    self.onFailureDueToInvalidAPIKeyWasCalled = YES;
}


@end
