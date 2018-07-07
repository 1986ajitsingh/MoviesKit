//
//  MockOperationQueue.m
//  MoviesKitTests
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import "MockOperationQueue.h"

@implementation MockOperationQueue

- (void)addOperation:(NSOperation *)op {
    self.addedOperation = (SearchMoviesOperation*) op;
}

- (void)cancelAllOperations {
    self.cancelAllOperationsGotCalled = YES;
}

- (void)waitUntilAllOperationsAreFinished {
    self.waitUntilAllOperationsAreFinishedGotCalled = YES;
}

@end
