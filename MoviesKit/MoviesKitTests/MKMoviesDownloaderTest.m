//
//  MKMoviesDownloaderTest.m
//  MoviesKitTests
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MKMoviesDownloader.h"
#import "TestCategories.h"
#import "MockOperationQueue.h"
#import "MockMKMoviesDownloader.h"
#import "../../SortMovies/MovieInfo.h"

@interface MKMoviesDownloader (Testing)
@property (nonatomic, strong) NSString* apiKey;

-(void)downloadLatestMoviesForSearchFilter:(NSString*)searchFilter withCompletionHandler:(void(^)(NSError *error, NSArray<IMovie> *movies))completionHandler;
-(void)proceedToSortingResults:(NSArray*) results;
-(void)finishWithFinalMoviesList:(NSArray*)finalMoviesList;
-(void)startOperationWithQueryString:(NSString*)queryString andYear:(NSString*)year andPage:(NSString*)page;
-(void)sendErrorResponseOnMainThread:(NSString*)errorDomain andErrorCode:(DownloadErrorCodes)errorCode andUserInfo:(NSDictionary*)userInfo;
-(MovieInfo*)getMovieInfoFromMovieDict:(NSDictionary*)movieDict;
-(char*)deepCopyNSStringToCString:(NSString*) str;
-(void)freeMovieInfo:(MovieInfo*)movieInfo;
-(void)onSuccessWithData:(NSData*) responseData andQueryString:(NSString*)queryString andYear:(NSString*)year;
-(void)onFailureDueToNetworkError;
-(void)onFailureDueToInvalidResponse;
-(void)onFailureDueToInvalidAPIKey;
@end


@interface MKMoviesDownloaderTest : XCTestCase

@end

@implementation MKMoviesDownloaderTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    // Arrange
    
    // Act
    MKMoviesDownloader *moviesDownloader = [[MKMoviesDownloader alloc] init];
    
    // Assert
    XCTAssertNil(moviesDownloader.apiKey);
}

- (void)testInitWithKey {
    // Arrange
    NSString *testAPIKey = @"Some test key";
    
    // Act
    MKMoviesDownloader *moviesDownloader = [[MKMoviesDownloader alloc] initWithAPIKey:testAPIKey];
    
    // Assert
    XCTAssertTrue([moviesDownloader.apiKey isEqualToString:testAPIKey]);
}

- (void)testSetAPIKey {
    // Arrange
    MKMoviesDownloader *moviesDownloader = [[MKMoviesDownloader alloc] init];
    NSString *testAPIKey = @"Some test key";
    
    // Act
    [moviesDownloader setAPIKey:testAPIKey];
    
    // Assert
    XCTAssertTrue([moviesDownloader.apiKey isEqualToString:testAPIKey]);
}

- (void)testDownloadLatestMoviesForSearchFilterWithNilAPIKey {
    // Arrange
    MockMKMoviesDownloader *moviesDownloader = [[MockMKMoviesDownloader alloc] init];
    void (^expectedCompletionHandler)(NSError *error, NSArray<IMovie> *movies) = ^void (NSError *error, NSArray<IMovie> *movies) {};
    
    // Act
    [moviesDownloader downloadLatestMoviesForSearchFilter:nil withCompletionHandler:expectedCompletionHandler];
    
    // Assert
    void (^completionHandler)(NSError *error, NSArray<IMovie> *movies) = [moviesDownloader valueForKey:@"_completionHandler"];
    XCTAssertEqual(completionHandler, expectedCompletionHandler);
    XCTAssertTrue(moviesDownloader.sendErrorResponseOnMainThreadGotCalled);
    XCTAssertTrue(moviesDownloader.errorCode == API_KET_IS_NOT_SET_ERROR);
    XCTAssertTrue([moviesDownloader.errorDomain isEqualToString:INVALID_STATE_ERROR_DOMAIN]);
    XCTAssertNil(moviesDownloader.userInfo);
}

- (void)testDownloadLatestMoviesForSearchFilterWithInvalidSearchFilter {
    // Arrange
    MockMKMoviesDownloader *moviesDownloader = [[MockMKMoviesDownloader alloc] initWithAPIKey:@"some api key"];
    void (^expectedCompletionHandler)(NSError *error, NSArray<IMovie> *movies) = ^void (NSError *error, NSArray<IMovie> *movies) {};
    
    // Act
    [moviesDownloader downloadLatestMoviesForSearchFilter:@"1" withCompletionHandler:expectedCompletionHandler];
    
    // Assert
    void (^completionHandler)(NSError *error, NSArray<IMovie> *movies) = [moviesDownloader valueForKey:@"_completionHandler"];
    XCTAssertEqual(completionHandler, expectedCompletionHandler);
    XCTAssertTrue(moviesDownloader.sendErrorResponseOnMainThreadGotCalled);
    XCTAssertTrue(moviesDownloader.errorCode == MINIMUM_TWO_CHARACTER_SEARCH_FILTER_REQUIRED_ERROR);
    XCTAssertTrue([moviesDownloader.errorDomain isEqualToString:INVALID_INPUT_ERROR_DOMAIN]);
    XCTAssertNil(moviesDownloader.userInfo);
}

- (void)testDownloadLatestMoviesForSearchFilterWithIsDownloading {
    // Arrange
    MockMKMoviesDownloader *moviesDownloader = [[MockMKMoviesDownloader alloc] initWithAPIKey:@"some api key"];
    void (^expectedCompletionHandler)(NSError *error, NSArray<IMovie> *movies) = ^void (NSError *error, NSArray<IMovie> *movies) {};
    [moviesDownloader setValue:[NSNumber numberWithBool:YES] forKey:@"_isDownloading"];
    
    // Act
    [moviesDownloader downloadLatestMoviesForSearchFilter:@"Batman" withCompletionHandler:expectedCompletionHandler];
    
    // Assert
    void (^completionHandler)(NSError *error, NSArray<IMovie> *movies) = [moviesDownloader valueForKey:@"_completionHandler"];
    XCTAssertEqual(completionHandler, expectedCompletionHandler);
    XCTAssertTrue(moviesDownloader.sendErrorResponseOnMainThreadGotCalled);
    XCTAssertTrue(moviesDownloader.errorCode == ANOTHER_DOWNLOAD_IS_IN_PROGRESS_ERROR);
    XCTAssertTrue([moviesDownloader.errorDomain isEqualToString:INVALID_STATE_ERROR_DOMAIN]);
    XCTAssertNil(moviesDownloader.userInfo);
}

- (void)testDownloadLatestMoviesForSearchFilterWithNoErrors {
    // Arrange
    MockMKMoviesDownloader *moviesDownloader = [[MockMKMoviesDownloader alloc] initWithAPIKey:@"some api key"];
    void (^expectedCompletionHandler)(NSError *error, NSArray<IMovie> *movies) = ^void (NSError *error, NSArray<IMovie> *movies) {};
    [moviesDownloader setValue:nil forKey:@"_downloadRawResults"];
    NSString *testQueryString = @"Batman";
    MockOperationQueue *operationQueue = [[MockOperationQueue alloc] init];
    [moviesDownloader setValue:operationQueue forKey:@"_operationQueue"];

    // Act
    [moviesDownloader downloadLatestMoviesForSearchFilter:testQueryString withCompletionHandler:expectedCompletionHandler];
    
    // Assert
    // Run the main loop briefly to let it call the async block
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    void (^completionHandler)(NSError *error, NSArray<IMovie> *movies) = [moviesDownloader valueForKey:@"_completionHandler"];
    XCTAssertEqual(completionHandler, expectedCompletionHandler);
    
    NSNumber* isDownloadNumberValue = [moviesDownloader valueForKey:@"_isDownloading"];
    XCTAssertTrue(isDownloadNumberValue.boolValue);
    
    NSMutableArray* downloadRawResults = [moviesDownloader valueForKey:@"_downloadRawResults"];
    XCTAssertNotNil(downloadRawResults);
    
    XCTAssertTrue(moviesDownloader.startOperationWithQueryStringCalledCount == 2);
    XCTAssertTrue([moviesDownloader.queryStringForStartOperation isEqualToString:testQueryString]);
    XCTAssertTrue([moviesDownloader.yearForStartOperation isEqualToString:YEAR_2017]);
    XCTAssertTrue([moviesDownloader.pageForStartOperation isEqualToString:@"1"]);

    XCTAssertTrue(operationQueue.waitUntilAllOperationsAreFinishedGotCalled);
    XCTAssertNotNil(moviesDownloader.proceedToSortingResultsInput);
}

- (void)testProceedToSortingResultsEmptyInputCase {
    // Arrange
    MockMKMoviesDownloader *moviesDownloader = [[MockMKMoviesDownloader alloc] init];
    moviesDownloader.proceedToSortingResultsShouldCallSuper = YES;
    
    // Act
    [moviesDownloader proceedToSortingResults:@[]];
    
    // Assert
    XCTAssertTrue(moviesDownloader.sendErrorResponseOnMainThreadGotCalled);
    XCTAssertTrue(moviesDownloader.errorCode == NO_MOVIES_FOUND_MATCHING_SEARCH_FILTER);
    XCTAssertTrue([moviesDownloader.errorDomain isEqualToString:DOWNLOAD_FAILED_ERROR_DOMAIN]);
    XCTAssertNil(moviesDownloader.userInfo);
}

- (void)testProceedToSortingResultsWithProperInput {
    // Arrange
    MockMKMoviesDownloader *moviesDownloader = [[MockMKMoviesDownloader alloc] init];
    moviesDownloader.proceedToSortingResultsShouldCallSuper = YES;
    NSArray *resultInput = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15"];
    NSMutableArray *testDownloadRawResults = [[NSMutableArray alloc] initWithObjects:@"1", @"2", nil];
    [moviesDownloader setValue:testDownloadRawResults forKey:@"_downloadRawResults"];
    
    // Act
    [moviesDownloader proceedToSortingResults:resultInput];
    
    // Assert
    XCTAssertTrue(moviesDownloader.getMovieInfoFromMovieDictCalledCount == resultInput.count);
    // 5 means resultInput.count - 10 (we show 10 movies)
    XCTAssertTrue(moviesDownloader.freeMovieInfoCalledCount == 5);
    XCTAssertTrue(testDownloadRawResults.count == 0);
    XCTAssertTrue(moviesDownloader.finalMoviesList.count == 10);
}

- (void)testFinishWithFinalMoviesList {
    // Arrange
    MKMoviesDownloader *moviesDownloader = [[MKMoviesDownloader alloc] init];
    NSArray *someTestArray = [[NSArray alloc] init];
    __block NSArray *resultArray = nil;
    void (^_completionHandler)(NSError *error, NSArray<IMovie> *movies) = ^void (NSError *error, NSArray<IMovie> *movies) {
        resultArray = movies;
    };
    [moviesDownloader setValue:_completionHandler forKey:@"_completionHandler"];
    
    // Act
    [moviesDownloader finishWithFinalMoviesList:someTestArray];
    
    // Assert
    // Run the main loop briefly to let it call the async block
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    NSNumber* isDownloadNumberValue = [moviesDownloader valueForKey:@"_isDownloading"];
    XCTAssertFalse(isDownloadNumberValue.boolValue);
    XCTAssertEqual(resultArray, someTestArray);
}

- (void)testStartOperationWithQueryString {
    // Arrange
    NSString *testQueryString = @"Some test query string";
    NSString *testYear = @"Some test year";
    NSString *testPage = @"Some test page";
    NSString *testAPIKey = @"Some test key";
    MKMoviesDownloader *moviesDownloader = [[MKMoviesDownloader alloc] initWithAPIKey:testAPIKey];
    MockOperationQueue *operationQueue = [[MockOperationQueue alloc] init];
    [moviesDownloader setValue:operationQueue forKey:@"_operationQueue"];
    
    // Act
    [moviesDownloader startOperationWithQueryString:testQueryString andYear:testYear andPage:testPage];
    
    // Assert
    SearchMoviesOperation *operation = operationQueue.addedOperation;
    XCTAssertNotNil(operation);
    XCTAssertNotNil(operation.urlSession);
    XCTAssertNotNil(operation.delegate);
    XCTAssertTrue([operation.queryString isEqualToString:testQueryString]);
    XCTAssertTrue([operation.year isEqualToString:testYear]);
    XCTAssertTrue([operation.page isEqualToString:testPage]);
    XCTAssertTrue([operation.apiKey isEqualToString:testAPIKey]);
}

- (void)testSendErrorResponseOnMainThread {
    // Arrange
    NSString *testErrorDomain = @"Some error domain";
    MKMoviesDownloader *moviesDownloader = [[MKMoviesDownloader alloc] init];
    __block NSError* receivedError = nil;
    void (^_completionHandler)(NSError *error, NSArray<IMovie> *movies) = ^void (NSError *error, NSArray<IMovie> *movies) {
        receivedError = error;
    };
    [moviesDownloader setValue:_completionHandler forKey:@"_completionHandler"];
    MockOperationQueue *operationQueue = [[MockOperationQueue alloc] init];
    [moviesDownloader setValue:operationQueue forKey:@"_operationQueue"];
    
    // Act
    [moviesDownloader sendErrorResponseOnMainThread:testErrorDomain andErrorCode:NETWORK_ERROR andUserInfo:nil];
    
    // Assert
    // Run the main loop briefly to let it call the async block
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    NSNumber* isDownloadNumberValue = [moviesDownloader valueForKey:@"_isDownloading"];
    XCTAssertFalse(isDownloadNumberValue.boolValue);
    XCTAssertTrue(receivedError.code == NETWORK_ERROR);
    XCTAssertTrue([receivedError.domain isEqualToString:testErrorDomain]);
    XCTAssertTrue(operationQueue.cancelAllOperationsGotCalled);
}

- (void)testGetMovieInfoFromMovieDictWithNilInput {
    // Arrange
    MKMoviesDownloader *moviesDownloader = [[MKMoviesDownloader alloc] init];
    
    // Act
    MovieInfo *movieInfo = [moviesDownloader getMovieInfoFromMovieDict:nil];
    
    // Assert
    XCTAssertTrue((movieInfo == nil));
}

- (void)testGetMovieInfoFromMovieDict {
    // Arrange
    MKMoviesDownloader *moviesDownloader = [[MKMoviesDownloader alloc] init];
    NSString *testTitle = @"Some test title";
    NSString *testPosterPath = @"Some poster path";
    NSString *testOverview = @"Some test overview";
    NSString *testReleaseDate = @"Some release date";
    NSDictionary *movieDict = @{
                                @"id": [NSNumber numberWithInteger:007],
                                @"vote_count": [NSNumber numberWithInteger:10],
                                @"vote_average": [NSNumber numberWithInteger:5],
                                @"title": testTitle,
                                @"poster_path": testPosterPath,
                                @"overview": testOverview,
                                @"release_date": testReleaseDate
                                };
    
    // Act
    MovieInfo *movieInfo = [moviesDownloader getMovieInfoFromMovieDict:movieDict];
    
    // Assert
    XCTAssertTrue(movieInfo->movieId == 007);
    XCTAssertTrue(movieInfo->voteCount == 10);
    XCTAssertTrue(movieInfo->voteAverage == 5);
    XCTAssertTrue(strcmp(movieInfo->title, testTitle.UTF8String) == 0);
    XCTAssertTrue(strcmp(movieInfo->posterPath, testPosterPath.UTF8String) == 0);
    XCTAssertTrue(strcmp(movieInfo->overview, testOverview.UTF8String) == 0);
    XCTAssertTrue(strcmp(movieInfo->releaseDate, testReleaseDate.UTF8String) == 0);
}

- (void)testDeepCopyNSStringToCString {
    // Arrange
    NSString *testString = @"Some test string";
    MKMoviesDownloader *moviesDownloader = [[MKMoviesDownloader alloc] init];
    
    // Act
    char *charStringResult = [moviesDownloader deepCopyNSStringToCString:testString];
    
    // Assert
    XCTAssertTrue(strcmp(charStringResult, testString.UTF8String) == 0);
}

- (void)testDeepCopyNSStringToCStringWithNilInput {
    // Arrange
    MKMoviesDownloader *moviesDownloader = [[MKMoviesDownloader alloc] init];
    
    // Act
    char *charStringResult = [moviesDownloader deepCopyNSStringToCString:nil];
    
    // Assert
    XCTAssertTrue((charStringResult == nil));
}

- (void)testFreeMovieInfo {
    // Arrange
    MKMoviesDownloader *moviesDownloader = [[MKMoviesDownloader alloc] init];
    MovieInfo *movieInfo = (MovieInfo *)malloc(sizeof(MovieInfo));
    movieInfo->movieId = 007;
    movieInfo->voteCount = 10;
    movieInfo->voteAverage = 5;
    movieInfo->title = [moviesDownloader deepCopyNSStringToCString:@"Some title"];
    movieInfo->posterPath = [moviesDownloader deepCopyNSStringToCString:@"Some poster path"];
    movieInfo->overview = [moviesDownloader deepCopyNSStringToCString:@"Some overview"];
    movieInfo->releaseDate = [moviesDownloader deepCopyNSStringToCString:@"Some release date"];
    
    // Act
    [moviesDownloader freeMovieInfo:movieInfo];

    // Assert
    // Assuming the test will crash if it fails.
    XCTAssertTrue(true);
}

- (void)testFreeMovieInfoNilInputCase {
    // Arrange
    MKMoviesDownloader *moviesDownloader = [[MKMoviesDownloader alloc] init];
    
    // Act
    [moviesDownloader freeMovieInfo:nil];
    
    // Assert
    // Assuming the test will crash if it fails.
    XCTAssertTrue(true);
}

- (void)testOnSuccessWithDataWithInvalidDataCase {
    // Arrange
    MockMKMoviesDownloader *moviesDownloader = [[MockMKMoviesDownloader alloc] init];
    
    // Act
    [moviesDownloader onSuccessWithData:[[NSData alloc] init] andQueryString:@"Some query string" andYear:@"Some year"];
    
    // Assert
    XCTAssertTrue(moviesDownloader.sendErrorResponseOnMainThreadGotCalled);
    XCTAssertTrue(moviesDownloader.errorCode == RESPONSE_PARSING_ERROR);
    XCTAssertTrue([moviesDownloader.errorDomain isEqualToString:DOWNLOAD_FAILED_ERROR_DOMAIN]);
    XCTAssertNil(moviesDownloader.userInfo);
}

- (void)testOnSuccessWithDataWithValidDataCase {
    // Arrange
    MockMKMoviesDownloader *moviesDownloader = [[MockMKMoviesDownloader alloc] init];
    NSString *testQueryString = @"Some query string";
    NSString *testYear = @"Some year";
    NSString *response = @"{\
        \"page\": 1,\
        \"total_results\": 20,\
        \"total_pages\": 2,\
        \"results\": [ \"Result 1\", \"Result 2\"]\
    }";
    NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *testDownloadRawResults = [[NSMutableArray alloc] init];
    [moviesDownloader setValue:testDownloadRawResults forKey:@"_downloadRawResults"];
    
    // Act
    [moviesDownloader onSuccessWithData:responseData andQueryString:testQueryString andYear:testYear];
    
    // Assert
    XCTAssertTrue(moviesDownloader.startOperationWithQueryStringGotCalled);
    XCTAssertTrue([moviesDownloader.queryStringForStartOperation isEqualToString:testQueryString]);
    XCTAssertTrue([moviesDownloader.yearForStartOperation isEqualToString:testYear]);
    XCTAssertTrue([moviesDownloader.pageForStartOperation isEqualToString:@"2"]);
    XCTAssertTrue(testDownloadRawResults.count == 2);
}

- (void)testOnFailureDueToNetworkError {
    // Arrange
    MockMKMoviesDownloader *moviesDownloader = [[MockMKMoviesDownloader alloc] init];
    
    // Act
    [moviesDownloader onFailureDueToNetworkError];
    
    // Assert
    XCTAssertTrue(moviesDownloader.sendErrorResponseOnMainThreadGotCalled);
    XCTAssertTrue(moviesDownloader.errorCode == NETWORK_ERROR);
    XCTAssertTrue([moviesDownloader.errorDomain isEqualToString:DOWNLOAD_FAILED_ERROR_DOMAIN]);
    XCTAssertNil(moviesDownloader.userInfo);
}

- (void)testOnFailureDueToInvalidResponse {
    // Arrange
    MockMKMoviesDownloader *moviesDownloader = [[MockMKMoviesDownloader alloc] init];
    
    // Act
    [moviesDownloader onFailureDueToInvalidResponse];
    
    // Assert
    XCTAssertTrue(moviesDownloader.sendErrorResponseOnMainThreadGotCalled);
    XCTAssertTrue(moviesDownloader.errorCode == INVALID_RESPONSE_ERROR);
    XCTAssertTrue([moviesDownloader.errorDomain isEqualToString:DOWNLOAD_FAILED_ERROR_DOMAIN]);
    XCTAssertNil(moviesDownloader.userInfo);
}

- (void)testOnFailureDueToInvalidAPIKey {
    // Arrange
    MockMKMoviesDownloader *moviesDownloader = [[MockMKMoviesDownloader alloc] init];
    
    // Act
    [moviesDownloader onFailureDueToInvalidAPIKey];
    
    // Assert
    XCTAssertTrue(moviesDownloader.sendErrorResponseOnMainThreadGotCalled);
    XCTAssertTrue(moviesDownloader.errorCode == INVALID_API_KEY_ERROR);
    XCTAssertTrue([moviesDownloader.errorDomain isEqualToString:DOWNLOAD_FAILED_ERROR_DOMAIN]);
    XCTAssertNil(moviesDownloader.userInfo);
}

@end
