//
//  SearchMoviesOperation.m
//  MoviesKit
//
//  Created by Ajit Singh on 05/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import "SearchMoviesOperation.h"

#define MOVIES_SEARCH_URL @"https://api.themoviedb.org/3/search/movie?api_key=%@&language=en-US&query=%@&page=%@&include_adult=false&primary_release_year=%@"

@interface SearchMoviesOperation ()
@property(nonatomic, strong) NSString *queryString;
@property(nonatomic, strong) NSString *year;
@property(nonatomic, strong) NSString *page;
@property(nonatomic, strong) NSString *apiKey;
@end

@implementation SearchMoviesOperation

-(id)init {
    return [self initWithQueryString:nil andYear:nil andPage:nil andAPIKey:nil];
}

-(id)initWithQueryString:(NSString*)queryString andYear:(NSString*)year andPage:(NSString*)page andAPIKey:(NSString*)apiKey {
    self = [super init];
    if (self) {
        self.queryString = queryString;
        self.year = year;
        self.page = page;
        self.apiKey = apiKey;
    }
    return self;
}

-(void)main {
    if (!self.apiKey || !self.queryString || !self.page || !self.year) {
        return;
    }
    
    NSString *finalSearchURL = [NSString stringWithFormat:MOVIES_SEARCH_URL, self.apiKey, self.queryString, self.page, self.year];
    NSURL *url = [NSURL URLWithString:finalSearchURL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL: url];
    NSURLSession *session = [NSURLSession sharedSession];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            if ([self.delegate respondsToSelector:@selector(onFailureDueToNetworkError)] && !self.isCancelled) {
                [self.delegate onFailureDueToNetworkError];
            }
            
        } else {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                if ([self.delegate respondsToSelector:@selector(onSuccessWithData:andQueryString:andYear:)] && !self.isCancelled) {
                    [self.delegate onSuccessWithData:data andQueryString:self.queryString andYear:self.year];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(onFailureDueToInvalidResponse)] && !self.isCancelled) {
                    [self.delegate onFailureDueToInvalidResponse];
                }
            }
        }
        
        dispatch_semaphore_signal(semaphore);
    }];

    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end
