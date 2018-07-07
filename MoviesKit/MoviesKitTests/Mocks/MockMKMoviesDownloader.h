//
//  MockMKMoviesDownloader.h
//  MoviesKitTests
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import <MoviesKit/MoviesKit.h>

@interface MockMKMoviesDownloader : MKMoviesDownloader

@property(nonatomic, strong) NSString* errorDomain;
@property(nonatomic, assign) DownloadErrorCodes errorCode;
@property(nonatomic, strong) NSDictionary *userInfo;
@property(nonatomic, assign) Boolean sendErrorResponseOnMainThreadGotCalled;

@property(nonatomic, assign) Boolean startOperationWithQueryStringGotCalled;
@property(nonatomic, assign) int startOperationWithQueryStringCalledCount;
@property(nonatomic, strong) NSString *queryStringForStartOperation;
@property(nonatomic, strong) NSString *yearForStartOperation;
@property(nonatomic, strong) NSString *pageForStartOperation;

@property(nonatomic, assign) int getMovieInfoFromMovieDictCalledCount;
@property(nonatomic, assign) int freeMovieInfoCalledCount;

@property(nonatomic, strong) NSArray *finalMoviesList;
@property(nonatomic, strong) NSArray *proceedToSortingResultsInput;
@property(nonatomic, assign) Boolean proceedToSortingResultsShouldCallSuper;

@end
