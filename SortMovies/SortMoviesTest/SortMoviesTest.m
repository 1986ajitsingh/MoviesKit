//
//  SortMoviesTest.m
//  SortMoviesTest
//
//  Created by Ajit Singh on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../SortMovies.h"
#import "../MovieInfo.h"

int compareMovies(const void *ptr1, const void *ptr2);

@interface SortMoviesTest : XCTestCase

@end

@implementation SortMoviesTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCompareMovie1GoesBeforeMovie2 {
    // Arrange
    MovieInfo *movie1 = (MovieInfo *)malloc(sizeof(MovieInfo));
    movie1->movieId = 1;
    movie1->voteCount = 10;
    movie1->voteAverage = 10;
    MovieInfo *movie2 = (MovieInfo *)malloc(sizeof(MovieInfo));
    movie2->movieId = 2;
    movie2->voteCount = 10;
    movie2->voteAverage = 5;
    
    // Act
    int result = compareMovies(&movie1, &movie2);
    
    // Assert
    XCTAssertTrue(result == -1);
}

- (void)testCompareMovie2GoesBeforeMovie1 {
    // Arrange
    MovieInfo *movie1 = (MovieInfo *)malloc(sizeof(MovieInfo));
    movie1->movieId = 1;
    movie1->voteCount = 10;
    movie1->voteAverage = 5;
    MovieInfo *movie2 = (MovieInfo *)malloc(sizeof(MovieInfo));
    movie2->movieId = 2;
    movie2->voteCount = 10;
    movie2->voteAverage = 10;
    
    // Act
    int result = compareMovies(&movie1, &movie2);
    
    // Assert
    XCTAssertTrue(result == 1);
}

- (void)testSortMoviesValidInput {
    // Arrange
    MovieInfo *movie1 = (MovieInfo *)malloc(sizeof(MovieInfo));
    movie1->movieId = 1;
    movie1->voteCount = 10;
    movie1->voteAverage = 5;
    MovieInfo *movie2 = (MovieInfo *)malloc(sizeof(MovieInfo));
    movie2->movieId = 2;
    movie2->voteCount = 10;
    movie2->voteAverage = 10;
    MovieInfo **movies = (MovieInfo **)malloc(2 * sizeof(MovieInfo *));
    movies[0] = movie1;
    movies[1] = movie2;
    
    // Act
    sortMovies(movies, 2);
    
    // Assert
    XCTAssertTrue(movies[0]->movieId == 2);
    XCTAssertTrue(movies[1]->movieId == 1);
}

- (void)testSortMovisNullInput {
    // Arrange
    
    // Act
    sortMovies(NULL, 0);
    
    // Assert
    // Assuming the test will crash if it fails.
    XCTAssertTrue(true);
}


@end
