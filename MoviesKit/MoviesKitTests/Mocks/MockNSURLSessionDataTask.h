//
//  MockNSURLSessionDataTask.h
//  MoviesKitTests
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MockNSURLSessionDataTask : NSURLSessionDataTask

@property(nonatomic, assign) Boolean resumeWasCalled;

@end
