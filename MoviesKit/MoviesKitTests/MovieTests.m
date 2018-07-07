//
//  MovieTests.m
//  MoviesKitTests
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Movie.h"

#define MOVIE_TEST_ID           00
#define MOVIE_TEST_VOTE_COUNT   10
#define MOVIE_TEST_VOTE_AVERAGE 5
#define MOVIE_TEST_TITLE        @"Some Movie Title"
#define MOVIE_TEST_POSTER_PATH  @"Some poster Path"
#define MOVIE_TEST_OVERVIEW     @"Some Movie overview"
#define MOVIE_TEST_RELEASE_DATE @"Some Release date"

@interface MovieTests : XCTestCase

@property(nonatomic, strong) id<IMovie> movieWithMovieInfo;
@property(nonatomic, strong) id<IMovie> movieWithoutMovieInfo;

@end

@implementation MovieTests

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

- (void)setUp {
    [super setUp];
    
    MovieInfo *movieInfo = (MovieInfo *)malloc(sizeof(MovieInfo));
    movieInfo->movieId = MOVIE_TEST_ID;
    movieInfo->voteCount = MOVIE_TEST_VOTE_COUNT;
    movieInfo->voteAverage = MOVIE_TEST_VOTE_AVERAGE;
    movieInfo->title = [self deepCopyNSStringToCString:MOVIE_TEST_TITLE];
    movieInfo->posterPath = [self deepCopyNSStringToCString:MOVIE_TEST_POSTER_PATH];
    movieInfo->overview = [self deepCopyNSStringToCString:MOVIE_TEST_OVERVIEW];
    movieInfo->releaseDate = [self deepCopyNSStringToCString:MOVIE_TEST_RELEASE_DATE];
    self.movieWithMovieInfo = [[Movie alloc] initWithMovieInfo:movieInfo];
    self.movieWithoutMovieInfo = [[Movie alloc] init];
}

- (void)tearDown {
    
    [super tearDown];
}

- (void)testMovieIdWithMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    // Already done in the setUp method
    
    // Assert
    XCTAssertEqual([self.movieWithMovieInfo getMovieId], MOVIE_TEST_ID);
}

- (void)testMovieVoteCountWithMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    // Already done in the setUp method
    
    // Assert
    XCTAssertEqual([self.movieWithMovieInfo getVoteCount], MOVIE_TEST_VOTE_COUNT);
}

- (void)testMovieVoteAverageWithMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    // Already done in the setUp method
    
    // Assert
    XCTAssertEqual([self.movieWithMovieInfo getVoteAverage], MOVIE_TEST_VOTE_AVERAGE);
}

- (void)testMovieTitleWithMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    NSString *title = [self.movieWithMovieInfo getTitle];
    
    // Assert
    XCTAssertTrue([title isEqualToString:MOVIE_TEST_TITLE]);
}

- (void)testMoviePosterPathWithMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    NSString *posterPath = [self.movieWithMovieInfo getPosterPath];
    
    // Assert
    XCTAssertTrue([posterPath isEqualToString:MOVIE_TEST_POSTER_PATH]);
}

- (void)testMovieOverviewWithMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    NSString *overview = [self.movieWithMovieInfo getOverview];
    
    // Assert
    XCTAssertTrue([overview isEqualToString:MOVIE_TEST_OVERVIEW]);
}

- (void)testMovieReleaseDateWithMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    NSString *releaseDate = [self.movieWithMovieInfo getReleaseDate];
    
    // Assert
    XCTAssertTrue([releaseDate isEqualToString:MOVIE_TEST_RELEASE_DATE]);
}

- (void)testMovieIdWithoutMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    // Already done in the setUp method
    
    // Assert
    XCTAssertEqual([self.movieWithoutMovieInfo getMovieId], 0);
}

- (void)testMovieVoteCountWithoutMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    // Already done in the setUp method
    
    // Assert
    XCTAssertEqual([self.movieWithoutMovieInfo getVoteCount], 0);
}

- (void)testMovieVoteAverageWithoutMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    // Already done in the setUp method
    
    // Assert
    XCTAssertEqual([self.movieWithoutMovieInfo getVoteAverage], 0);
}

- (void)testMovieTitleWithoutMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    NSString *title = [self.movieWithoutMovieInfo getTitle];
    
    // Assert
    XCTAssertNil(title);
}

- (void)testMoviePosterPathWithoutMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    NSString *posterPath = [self.movieWithoutMovieInfo getPosterPath];
    
    // Assert
    XCTAssertNil(posterPath);
}

- (void)testMovieOverviewWithoutMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    NSString *overview = [self.movieWithoutMovieInfo getOverview];
    
    // Assert
    XCTAssertNil(overview);
}

- (void)testMovieReleaseDateWithoutMovieInfo {
    // Arrange
    // Already done in the setUp method
    
    // Act
    NSString *releaseDate = [self.movieWithoutMovieInfo getReleaseDate];
    
    // Assert
    XCTAssertNil(releaseDate);
}

- (void)testMovieDealloc {
    // Arrange
    MovieInfo *movieInfo = (MovieInfo *)malloc(sizeof(MovieInfo));
    movieInfo->movieId = MOVIE_TEST_ID;
    movieInfo->voteCount = MOVIE_TEST_VOTE_COUNT;
    movieInfo->voteAverage = MOVIE_TEST_VOTE_AVERAGE;
    movieInfo->title = [self deepCopyNSStringToCString:MOVIE_TEST_TITLE];
    movieInfo->posterPath = [self deepCopyNSStringToCString:MOVIE_TEST_POSTER_PATH];
    movieInfo->overview = [self deepCopyNSStringToCString:MOVIE_TEST_OVERVIEW];
    movieInfo->releaseDate = [self deepCopyNSStringToCString:MOVIE_TEST_RELEASE_DATE];
    
    // Act
    Movie* __weak movie = [[Movie alloc] initWithMovieInfo:movieInfo];
    
    // Assert
    XCTAssertNil([movie getTitle]);
    XCTAssertNil([movie getPosterPath]);
    XCTAssertNil([movie getOverview]);
    XCTAssertNil([movie getReleaseDate]);
}

- (void)testMovieDeallocWithNoMovieInfo {
    // Arrange
    
    // Act
    Movie* __weak movie = [[Movie alloc] init];
    
    // Assert
    XCTAssertNil([movie getTitle]);
    XCTAssertNil([movie getPosterPath]);
    XCTAssertNil([movie getOverview]);
    XCTAssertNil([movie getReleaseDate]);
}


@end
