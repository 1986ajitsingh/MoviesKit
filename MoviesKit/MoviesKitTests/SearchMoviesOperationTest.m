//
//  SearchMoviesOperationTest.m
//  MoviesKitTests
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SearchMoviesOperation.h"
#import "MockURLSession.h"
#import "MockSearchMoviesOperationDelegate.h"

@interface SearchMoviesOperation (Testing)
@property(nonatomic, strong) NSString *queryString;
@property(nonatomic, strong) NSString *year;
@property(nonatomic, strong) NSString *page;
@property(nonatomic, strong) NSString *apiKey;
@end

@interface SearchMoviesOperationTest : XCTestCase

@property(nonatomic, strong) SearchMoviesOperation *operation;

@end

#define TEST_QUERY_STRING   @"Some Query String"
#define TEST_YEAR           @"Some year"
#define TEST_PAGE           @"Some page"
#define TEST_API_KEY        @"Some API Key"

@implementation SearchMoviesOperationTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.operation = [[SearchMoviesOperation alloc] initWithQueryString:TEST_QUERY_STRING andYear:TEST_YEAR andPage:TEST_PAGE andAPIKey:TEST_API_KEY];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testProperInitialization {
    // Arrange
    // Already done in the setup method
    
    // Act
    // Already done in the setup method
    
    // Assert
    XCTAssertTrue([self.operation.queryString isEqualToString:TEST_QUERY_STRING]);
    XCTAssertTrue([self.operation.year isEqualToString:TEST_YEAR]);
    XCTAssertTrue([self.operation.page isEqualToString:TEST_PAGE]);
    XCTAssertTrue([self.operation.apiKey isEqualToString:TEST_API_KEY]);
}

- (void)testImproperInitialization {
    // Arrange
    SearchMoviesOperation *operation = [[SearchMoviesOperation alloc] init];
    
    // Act
    // nothing to do here
    
    // Assert
    XCTAssertNil(operation.queryString);
    XCTAssertNil(operation.year);
    XCTAssertNil(operation.page);
    XCTAssertNil(operation.apiKey);
}

- (void)testMainTaskResumeShouldNotBeCalled {
    // Arrange
    SearchMoviesOperation *operation = [[SearchMoviesOperation alloc] init];
    MockURLSession* mockURLSession = [[MockURLSession alloc] init];
    MockNSURLSessionDataTask *mockNSURLSessionDataTask = [[MockNSURLSessionDataTask alloc] init];
    mockURLSession.mockNSURLSessionDataTask = mockNSURLSessionDataTask;
    operation.urlSession = mockURLSession;
    
    // Act
    [operation main];
    
    // Assert
    XCTAssertFalse(mockNSURLSessionDataTask.resumeWasCalled);
}

- (void)testMainRequestAndTaskResume {
    // Arrange
    MockURLSession* mockURLSession = [[MockURLSession alloc] init];
    MockNSURLSessionDataTask *mockNSURLSessionDataTask = [[MockNSURLSessionDataTask alloc] init];
    mockURLSession.mockNSURLSessionDataTask = mockNSURLSessionDataTask;
    self.operation.urlSession = mockURLSession;
    
    NSString *expectedURL = @"https://api.themoviedb.org/3/search/movie?api_key=Some%20API%20Key&language=en-US&query=Some%20Query%20String&page=Some%20page&include_adult=false&primary_release_year=Some%20year";
    
    // Act
    [self.operation main];
    
    // Assert
    XCTAssertTrue([mockURLSession.inputRequest.URL.absoluteString isEqualToString:expectedURL]);
    XCTAssertTrue(mockNSURLSessionDataTask.resumeWasCalled);
}

- (void)testMainSuccessWithData {
    // Arrange
    MockURLSession* mockURLSession = [[MockURLSession alloc] init];
    MockNSURLSessionDataTask *mockNSURLSessionDataTask = [[MockNSURLSessionDataTask alloc] init];
    MockSearchMoviesOperationDelegate *delegate = [[MockSearchMoviesOperationDelegate alloc] init];
    mockURLSession.mockNSURLSessionDataTask = mockNSURLSessionDataTask;
    self.operation.urlSession = mockURLSession;
    self.operation.delegate = delegate;
    
    // set response code to 200
    mockURLSession.outputHttpResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] init] statusCode:200 HTTPVersion:@"" headerFields:nil];
    NSData* testData = [[NSData alloc] init];
    mockURLSession.outputData = testData;
    
    // Act
    [self.operation main];
    
    // Assert
    XCTAssertEqual(delegate.responseData, testData);
    XCTAssertTrue([delegate.queryString isEqualToString:TEST_QUERY_STRING]);
    XCTAssertTrue([delegate.year isEqualToString:TEST_YEAR]);
    XCTAssertTrue(delegate.onSuccessWithDataWasCalled);
    XCTAssertFalse(delegate.onFailureDueToNetworkErrorWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidResponseWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidAPIKeyWasCalled);
}

- (void)testMainFailureDueToNetworkError {
    // Arrange
    MockURLSession* mockURLSession = [[MockURLSession alloc] init];
    MockNSURLSessionDataTask *mockNSURLSessionDataTask = [[MockNSURLSessionDataTask alloc] init];
    MockSearchMoviesOperationDelegate *delegate = [[MockSearchMoviesOperationDelegate alloc] init];
    mockURLSession.mockNSURLSessionDataTask = mockNSURLSessionDataTask;
    self.operation.urlSession = mockURLSession;
    self.operation.delegate = delegate;
    
    // Give some error
    mockURLSession.outputError = [[NSError alloc] init];
    
    // Act
    [self.operation main];
    
    // Assert
    XCTAssertFalse(delegate.onSuccessWithDataWasCalled);
    XCTAssertTrue(delegate.onFailureDueToNetworkErrorWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidResponseWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidAPIKeyWasCalled);
}


- (void)testMainFailureDueToInvalidResponse {
    // Arrange
    MockURLSession* mockURLSession = [[MockURLSession alloc] init];
    MockNSURLSessionDataTask *mockNSURLSessionDataTask = [[MockNSURLSessionDataTask alloc] init];
    MockSearchMoviesOperationDelegate *delegate = [[MockSearchMoviesOperationDelegate alloc] init];
    mockURLSession.mockNSURLSessionDataTask = mockNSURLSessionDataTask;
    self.operation.urlSession = mockURLSession;
    self.operation.delegate = delegate;
    
    // set response code to 500
    mockURLSession.outputHttpResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] init] statusCode:500 HTTPVersion:@"" headerFields:nil];
    
    // Act
    [self.operation main];
    
    // Assert
    XCTAssertFalse(delegate.onSuccessWithDataWasCalled);
    XCTAssertFalse(delegate.onFailureDueToNetworkErrorWasCalled);
    XCTAssertTrue(delegate.onFailureDueToInvalidResponseWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidAPIKeyWasCalled);
}

- (void)testMainFailureDueToInvalidAPIKey {
    // Arrange
    MockURLSession* mockURLSession = [[MockURLSession alloc] init];
    MockNSURLSessionDataTask *mockNSURLSessionDataTask = [[MockNSURLSessionDataTask alloc] init];
    MockSearchMoviesOperationDelegate *delegate = [[MockSearchMoviesOperationDelegate alloc] init];
    mockURLSession.mockNSURLSessionDataTask = mockNSURLSessionDataTask;
    self.operation.urlSession = mockURLSession;
    self.operation.delegate = delegate;
    
    // set response code to 401
    mockURLSession.outputHttpResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] init] statusCode:401 HTTPVersion:@"" headerFields:nil];
    
    // Act
    [self.operation main];
    
    // Assert
    XCTAssertFalse(delegate.onSuccessWithDataWasCalled);
    XCTAssertFalse(delegate.onFailureDueToNetworkErrorWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidResponseWasCalled);
    XCTAssertTrue(delegate.onFailureDueToInvalidAPIKeyWasCalled);
}

// test for cases, when operation is in cancel state
- (void)testMainSuccessWithDataWhenOperationIsCanceled {
    // Arrange
    MockURLSession* mockURLSession = [[MockURLSession alloc] init];
    MockNSURLSessionDataTask *mockNSURLSessionDataTask = [[MockNSURLSessionDataTask alloc] init];
    MockSearchMoviesOperationDelegate *delegate = [[MockSearchMoviesOperationDelegate alloc] init];
    mockURLSession.mockNSURLSessionDataTask = mockNSURLSessionDataTask;
    self.operation.urlSession = mockURLSession;
    self.operation.delegate = delegate;
    
    // set response code to 200
    mockURLSession.outputHttpResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] init] statusCode:200 HTTPVersion:@"" headerFields:nil];
    // cancel operation
    [self.operation cancel];
    
    // Act
    [self.operation main];
    
    // Assert
    XCTAssertFalse(delegate.onSuccessWithDataWasCalled);
    XCTAssertFalse(delegate.onFailureDueToNetworkErrorWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidResponseWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidAPIKeyWasCalled);
}

- (void)testMainFailureDueToNetworkErrorWhenOperationIsCanceled {
    // Arrange
    MockURLSession* mockURLSession = [[MockURLSession alloc] init];
    MockNSURLSessionDataTask *mockNSURLSessionDataTask = [[MockNSURLSessionDataTask alloc] init];
    MockSearchMoviesOperationDelegate *delegate = [[MockSearchMoviesOperationDelegate alloc] init];
    mockURLSession.mockNSURLSessionDataTask = mockNSURLSessionDataTask;
    self.operation.urlSession = mockURLSession;
    self.operation.delegate = delegate;
    
    // Give some error
    mockURLSession.outputError = [[NSError alloc] init];
    // cancel operation
    [self.operation cancel];
    
    // Act
    [self.operation main];
    
    // Assert
    XCTAssertFalse(delegate.onSuccessWithDataWasCalled);
    XCTAssertFalse(delegate.onFailureDueToNetworkErrorWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidResponseWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidAPIKeyWasCalled);
}


- (void)testMainFailureDueToInvalidResponseWhenOperationIsCanceled {
    // Arrange
    MockURLSession* mockURLSession = [[MockURLSession alloc] init];
    MockNSURLSessionDataTask *mockNSURLSessionDataTask = [[MockNSURLSessionDataTask alloc] init];
    MockSearchMoviesOperationDelegate *delegate = [[MockSearchMoviesOperationDelegate alloc] init];
    mockURLSession.mockNSURLSessionDataTask = mockNSURLSessionDataTask;
    self.operation.urlSession = mockURLSession;
    self.operation.delegate = delegate;
    
    // set response code to 500
    mockURLSession.outputHttpResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] init] statusCode:500 HTTPVersion:@"" headerFields:nil];
    // cancel operation
    [self.operation cancel];
    
    // Act
    [self.operation main];
    
    // Assert
    XCTAssertFalse(delegate.onSuccessWithDataWasCalled);
    XCTAssertFalse(delegate.onFailureDueToNetworkErrorWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidResponseWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidAPIKeyWasCalled);
}

- (void)testMainFailureDueToInvalidAPIKeyWhenOperationIsCanceled {
    // Arrange
    MockURLSession* mockURLSession = [[MockURLSession alloc] init];
    MockNSURLSessionDataTask *mockNSURLSessionDataTask = [[MockNSURLSessionDataTask alloc] init];
    MockSearchMoviesOperationDelegate *delegate = [[MockSearchMoviesOperationDelegate alloc] init];
    mockURLSession.mockNSURLSessionDataTask = mockNSURLSessionDataTask;
    self.operation.urlSession = mockURLSession;
    self.operation.delegate = delegate;
    
    // set response code to 401
    mockURLSession.outputHttpResponse = [[NSHTTPURLResponse alloc] initWithURL:[[NSURL alloc] init] statusCode:401 HTTPVersion:@"" headerFields:nil];
    // cancel operation
    [self.operation cancel];
    
    // Act
    [self.operation main];
    
    // Assert
    XCTAssertFalse(delegate.onSuccessWithDataWasCalled);
    XCTAssertFalse(delegate.onFailureDueToNetworkErrorWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidResponseWasCalled);
    XCTAssertFalse(delegate.onFailureDueToInvalidAPIKeyWasCalled);
}

@end
