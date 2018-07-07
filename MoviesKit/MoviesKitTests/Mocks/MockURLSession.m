//
//  MockURLSession.m
//  MoviesKitTests
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import "MockURLSession.h"

@implementation MockURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    self.inputRequest = request;
    completionHandler(self.outputData, self.outputHttpResponse, self.outputError);
    return self.mockNSURLSessionDataTask;
}

@end
