//
//  MKMoviesDownloader.m
//  MoviesKit
//
//  Created by Ajit Singh on 04/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import "MKMoviesDownloader.h"
#import "../../SortMovies/SortMovies.h"
#import "../../SortMovies/MovieInfo.h"
#import "Movie.h"
#import "SearchMoviesOperation.h"

@interface MKMoviesDownloader() <SearchMoviesOperationDelegate> {
@private
//    void (^_completionHandler)(NSError *error, NSArray<IMovie> *movies);
//    Boolean _isDownloading;
//    NSMutableArray *_downloadRawResults;
//    NSOperationQueue *_operationQueue;
}
    @property (nonatomic, strong) NSString* apiKey;
    @property (nonatomic, strong) NSOperationQueue *operationQueue;
    @property (nonatomic, strong) NSMutableArray *downloadRawResults;
    @property (nonatomic, assign) Boolean isDownloading;
    @property (nonatomic, strong) void (^completionHandler)(NSError *error, NSArray<IMovie> *movies);
@end

@implementation MKMoviesDownloader

-(id)init {
    return [self initWithAPIKey:nil];
}

-(id)initWithAPIKey:(NSString*) apiKey {
    self = [super init];
    if (self) {
        self.apiKey = apiKey;
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 5;
    }
    return self;
}

-(void)setAPIKey:(NSString*) apiKey {
    self.apiKey = apiKey;
}

-(void)downloadLatestMoviesForSearchFilter:(NSString*)searchFilter
                     withCompletionHandler:(void(^)(NSError *error, NSArray<IMovie> *movies))completionHandler {
    
    self.completionHandler = completionHandler;
    
    if (self.apiKey == nil) {
        [self sendErrorResponseOnMainThread:INVALID_STATE_ERROR_DOMAIN
                               andErrorCode:API_KET_IS_NOT_SET_ERROR
                                andUserInfo:nil];
        return;
    }
    
    // Hence minimum 2 characters search filter is required
    if (searchFilter.length < 2) {
        [self sendErrorResponseOnMainThread:INVALID_INPUT_ERROR_DOMAIN
                               andErrorCode:MINIMUM_TWO_CHARACTER_SEARCH_FILTER_REQUIRED_ERROR
                                andUserInfo:nil];
        return;
    }
    
    if (self.isDownloading) {
        [self sendErrorResponseOnMainThread:INVALID_STATE_ERROR_DOMAIN
                               andErrorCode:ANOTHER_DOWNLOAD_IS_IN_PROGRESS_ERROR
                                andUserInfo:nil];
        return;
    }
    
    self.isDownloading = true;
    self.downloadRawResults = [[NSMutableArray alloc] init];
    
    [self startOperationWithQueryString:searchFilter andYear:YEAR_2018 andPage:@"1"];
    [self startOperationWithQueryString:searchFilter andYear:YEAR_2017 andPage:@"1"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.operationQueue waitUntilAllOperationsAreFinished];
        // Control will come here once all the download operations are complete
        // hence, proceed to sorting the results from here.
        // check if state is still isDownloading,
        // if not then it means, there was an error hence do nothing
        if (self.isDownloading) {
            [self proceedToSortingResults:self.downloadRawResults];
        }
    });
}

#pragma mark - Private helper functions
-(void)proceedToSortingResults:(NSArray*) results {
    if (results.count == 0) {
        [self sendErrorResponseOnMainThread:DOWNLOAD_FAILED_ERROR_DOMAIN
                               andErrorCode:NO_MOVIES_FOUND_MATCHING_SEARCH_FILTER
                                andUserInfo:nil];
        
    } else {
        MovieInfo **movies = (MovieInfo **)malloc(results.count * sizeof(MovieInfo *));
        
        for (int index = 0 ; index < results.count ; index++) {
            movies[index] = [self getMovieInfoFromMovieDict:results[index]];
        }
        
        // Use C library function to sort movies
        sortMovies(movies, results.count);
        
        // From sorted movies, create Movie class objects for 10 or less.
        // Then release the rest of the MovieInfo objects (if any)
        NSMutableArray *topRatedMovies = [[NSMutableArray alloc] init];
        for (int index = 0 ; index < results.count ; index++) {
            if (index < 10) {
                Movie *movie = [[Movie alloc] initWithMovieInfo:movies[index]];
                [topRatedMovies addObject:movie];
            } else {
                [self freeMovieInfo:movies[index]];
            }
        }
        
        // Clear the downloadRawResults and movies array since it's no more required
        [self.downloadRawResults removeAllObjects];
        free(movies);
        
        [self finishWithFinalMoviesList:topRatedMovies];
    }
}

-(void)finishWithFinalMoviesList:(NSArray*)finalMoviesList {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.isDownloading = false;
        // return the final 10 or less objects to the completion block.
        self.completionHandler(nil, (NSArray<IMovie> *)finalMoviesList);
    });
}

-(void)startOperationWithQueryString:(NSString*)queryString
                             andYear:(NSString*)year
                             andPage:(NSString*)page {
    SearchMoviesOperation *operation = [[SearchMoviesOperation alloc]
                                        initWithQueryString:queryString
                                        andYear:year andPage:page
                                        andAPIKey:self.apiKey];
    operation.urlSession = [NSURLSession sharedSession];
    operation.delegate = self;
    [self.operationQueue addOperation:operation];
}

-(void)sendErrorResponseOnMainThread:(NSString*)errorDomain
                        andErrorCode:(DownloadErrorCodes)errorCode
                         andUserInfo:(NSDictionary*)userInfo {
    
    self.isDownloading = false;
    [self.operationQueue cancelAllOperations];
    
    NSError *error = [[NSError alloc] initWithDomain:errorDomain code:errorCode userInfo:userInfo];
    if ([NSThread isMainThread]) {
        self.completionHandler(error, nil);
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.completionHandler(error, nil);
        });
    }
}

-(MovieInfo*)getMovieInfoFromMovieDict:(NSDictionary*)movieDict {
    
    if(movieDict == nil)
        return nil;

    NSNumber *movieIdNumber = (NSNumber *)movieDict[@"id"];
    NSNumber *voteCountNumber = (NSNumber *)movieDict[@"vote_count"];
    NSNumber *voteAverageNumber = (NSNumber *)movieDict[@"vote_average"];
    NSString *title = movieDict[@"title"];
    NSString *posterPath = movieDict[@"poster_path"];
    NSString *overview = movieDict[@"overview"];
    NSString *releaseDate = movieDict[@"release_date"];
    
    MovieInfo *movieInfo = (MovieInfo *)malloc(sizeof(MovieInfo));
    movieInfo->movieId = movieIdNumber.longValue;
    movieInfo->voteCount = voteCountNumber.intValue;
    movieInfo->voteAverage = voteAverageNumber.intValue;
    movieInfo->title = [self deepCopyNSStringToCString:title];
    movieInfo->posterPath = [self deepCopyNSStringToCString:posterPath];
    movieInfo->overview = [self deepCopyNSStringToCString:overview];
    movieInfo->releaseDate = [self deepCopyNSStringToCString:releaseDate];
    
    return movieInfo;
}

-(char*)deepCopyNSStringToCString:(NSString*) str {
    if (str == (id)[NSNull null] || str.length == 0 )  {
        return nil;
    }
    const char *cStr = [str UTF8String];
    char *copy = (char*)malloc(str.length + 1);
    memset(copy, '\0', str.length + 1);
    strncpy(copy, cStr, str.length);
    return copy;
}

-(void)freeMovieInfo:(MovieInfo*)movieInfo {
    if (movieInfo == nil) {
        return;
    }
    
    if (movieInfo->title != nil) {
        free(movieInfo->title);
        movieInfo->title = nil;
    }
    if (movieInfo->posterPath != nil) {
        free(movieInfo->posterPath);
        movieInfo->posterPath = nil;
    }
    if (movieInfo->overview != nil) {
        free(movieInfo->overview);
        movieInfo->overview = nil;
    }
    if (movieInfo->releaseDate != nil) {
        free(movieInfo->releaseDate);
        movieInfo->releaseDate = nil;
    }
    
    free(movieInfo);
}

#pragma mark - SearchMoviesOperationDelegate methods
-(void)onSuccessWithData:(NSData*) responseData
          andQueryString:(NSString*)queryString
                 andYear:(NSString*)year {
    NSError *parseError = nil;
    NSDictionary *jsonDict = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:0
                              error:&parseError];
    if (parseError == nil) {
        NSArray *results = jsonDict[@"results"];
        [self.downloadRawResults addObjectsFromArray:results];
        
        NSNumber *totalPages = jsonDict[@"total_pages"];
        NSNumber *page = jsonDict[@"page"];
        
        // If current page is 1 and there are more pages, then fetch them all
        if ( page.intValue == 1 && totalPages.intValue > 1 ) {
            for (int pageNumber = 2 ; pageNumber <= totalPages.intValue ; pageNumber++) {
                NSString *pageString = [NSString stringWithFormat:@"%d", pageNumber];
                [self startOperationWithQueryString:queryString andYear:year andPage:pageString];
            }
        }
    } else {
        [self sendErrorResponseOnMainThread:DOWNLOAD_FAILED_ERROR_DOMAIN
                               andErrorCode:RESPONSE_PARSING_ERROR
                                andUserInfo:nil];
    }
}

-(void)onFailureDueToNetworkError {
    [self sendErrorResponseOnMainThread:DOWNLOAD_FAILED_ERROR_DOMAIN
                           andErrorCode:NETWORK_ERROR
                            andUserInfo:nil];
}

-(void)onFailureDueToInvalidResponse {
    [self sendErrorResponseOnMainThread:DOWNLOAD_FAILED_ERROR_DOMAIN
                           andErrorCode:INVALID_RESPONSE_ERROR
                            andUserInfo:nil];
}

-(void)onFailureDueToInvalidAPIKey {
    [self sendErrorResponseOnMainThread:DOWNLOAD_FAILED_ERROR_DOMAIN
                           andErrorCode:INVALID_API_KEY_ERROR
                            andUserInfo:nil];
}
@end
