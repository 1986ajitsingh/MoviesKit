//
//  MockMKMoviesDownloader.m
//  MoviesKitTests
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import "MockMKMoviesDownloader.h"
#import "../../../SortMovies/MovieInfo.h"

@interface MKMoviesDownloader (Testing)
-(char*)deepCopyNSStringToCString:(NSString*) str;
-(void)proceedToSortingResults:(NSArray*) results;
@end

@implementation MockMKMoviesDownloader

-(void)sendErrorResponseOnMainThread:(NSString*)errorDomain andErrorCode:(DownloadErrorCodes)errorCode andUserInfo:(NSDictionary*)userInfo {
    self.sendErrorResponseOnMainThreadGotCalled = YES;
    self.errorDomain = errorDomain;
    self.errorCode = errorCode;
    self.userInfo = userInfo;
}

-(void)startOperationWithQueryString:(NSString*)queryString andYear:(NSString*)year andPage:(NSString*)page {
    self.startOperationWithQueryStringCalledCount += 1;
    self.startOperationWithQueryStringGotCalled = YES;
    self.queryStringForStartOperation = queryString;
    self.yearForStartOperation = year;
    self.pageForStartOperation = page;
}

-(MovieInfo*)getMovieInfoFromMovieDict:(NSDictionary*)movieDict {
    self.getMovieInfoFromMovieDictCalledCount += 1;
    
    MovieInfo *movieInfo = (MovieInfo *)malloc(sizeof(MovieInfo));
    movieInfo->movieId = 007;
    movieInfo->voteCount = 10;
    movieInfo->voteAverage = 5;
    movieInfo->title = [super deepCopyNSStringToCString:@"Some title"];
    movieInfo->posterPath = [super deepCopyNSStringToCString:@"Some poster path"];
    movieInfo->overview = [super deepCopyNSStringToCString:@"Some overview"];
    movieInfo->releaseDate = [super deepCopyNSStringToCString:@"Some release date"];
    return  movieInfo;
}

-(void)freeMovieInfo:(MovieInfo*)movieInfo {
    self.freeMovieInfoCalledCount += 1;
}

-(void)finishWithFinalMoviesList:(NSArray*)finalMoviesList {
    self.finalMoviesList = finalMoviesList;
}

-(void)proceedToSortingResults:(NSArray*) results {
    if (self.proceedToSortingResultsShouldCallSuper == YES) {
        [super proceedToSortingResults:results];
    } else {
        self.proceedToSortingResultsInput = results;
    }
}

@end
