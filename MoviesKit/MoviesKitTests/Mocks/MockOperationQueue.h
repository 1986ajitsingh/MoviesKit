//
//  MockOperationQueue.h
//  MoviesKitTests
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchMoviesOperation.h"

@interface MockOperationQueue : NSOperationQueue

@property(nonatomic, strong) SearchMoviesOperation *addedOperation;
@property(nonatomic, assign) Boolean cancelAllOperationsGotCalled;
@property(nonatomic, assign) Boolean waitUntilAllOperationsAreFinishedGotCalled;
@end
