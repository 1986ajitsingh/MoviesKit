//
//  SearchMoviesOperation.h
//  MoviesKit
//
//  Created by Ajit Singh on 05/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YEAR_2018 @"2018"
#define YEAR_2017 @"2017"

@protocol SearchMoviesOperationDelegate <NSObject>
@required
-(void)onSuccessWithData:(NSData*) responseData andQueryString:(NSString*)queryString andYear:(NSString*)year;
-(void)onFailureDueToNetworkError;
-(void)onFailureDueToInvalidResponse;
-(void)onFailureDueToInvalidAPIKey;
@end

@interface SearchMoviesOperation : NSOperation

@property(nonatomic, weak) id<SearchMoviesOperationDelegate> delegate;
// Dependency injection:: Injecting the session object to make this
// class testable
@property(nonatomic, strong) NSURLSession *urlSession;

-(id)initWithQueryString:(NSString*)queryString andYear:(NSString*)year andPage:(NSString*)page andAPIKey:(NSString*)apiKey;

@end
