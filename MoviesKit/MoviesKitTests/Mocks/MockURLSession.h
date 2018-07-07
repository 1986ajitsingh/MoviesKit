//
//  MockURLSession.h
//  MoviesKitTests
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MockNSURLSessionDataTask.h"

@interface MockURLSession : NSURLSession

@property(nonatomic, strong) NSError *outputError;
@property(nonatomic, strong) NSHTTPURLResponse *outputHttpResponse;
@property(nonatomic, strong) NSData *outputData;
@property(nonatomic, strong) MockNSURLSessionDataTask *mockNSURLSessionDataTask;

@property(nonatomic, strong) NSURLRequest *inputRequest;

@end
