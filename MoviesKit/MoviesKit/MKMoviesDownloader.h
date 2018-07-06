//
//  MKMoviesDownloader.h
//  MoviesKit
//
//  Created by Ajit Singh on 04/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMovie.h"

typedef enum downloadErrorCodes
{
    MINIMUM_TWO_CHARACTER_SEARCH_FILTER_REQUIRED_ERROR = 100,
    ANOTHER_DOWNLOAD_IS_IN_PROGRESS_ERROR,
    API_KET_IS_NOT_SET_ERROR,
    NETWORK_ERROR,
    INVALID_RESPONSE_ERROR,
    RESPONSE_PARSING_ERROR,
    NO_MOVIES_FOUND_MATCHING_SEARCH_FILTER
} DownloadErrorCodes;

#define INVALID_INPUT_ERROR_DOMAIN        @"InvalidInputErrorDomain"
#define INVALID_STATE_ERROR_DOMAIN        @"InvalidStateErrorDomain"
#define DOWNLOAD_FAILED_ERROR_DOMAIN      @"DownloadFailedErrorDomain"

@interface MKMoviesDownloader : NSObject

-(id)initWithAPIKey:(NSString*) apiKey;

-(void)setAPIKey:(NSString*) apiKey;

-(void)downloadLatestMoviesForSearchFilter:(NSString*)searchFilter withCompletionHandler:(void(^)(NSError *error, NSArray<IMovie> *movies))completionHandler;

@end
