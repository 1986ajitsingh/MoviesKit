//
//  MockNSURLSessionDataTask.m
//  MoviesKitTests
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import "MockNSURLSessionDataTask.h"

@implementation MockNSURLSessionDataTask

-(id) init {
    self = [super init];
    if (self) {
        self.resumeWasCalled = NO;
    }
    return self;
}

-(void)resume {
    self.resumeWasCalled = YES;
}

@end
