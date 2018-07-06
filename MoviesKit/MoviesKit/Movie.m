//
//  Movie.m
//  MoviesKit
//
//  Created by Ajit Singh on 04/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import "Movie.h"

@interface Movie() {
    MovieInfo* movieInfo;
}
@end

@implementation Movie

-(id)init {
    return [self initWithMovieInfo:nil];
}

-(id)initWithMovieInfo:(MovieInfo*)movieInfo {
    self = [super init];
    if (self) {
        self->movieInfo = movieInfo;
    }
    return self;
}

-(void)dealloc {
    if (movieInfo != nil)
        free(movieInfo);
    else
        return;
    
    if (movieInfo->title != nil)
        free(movieInfo->title);
    if (movieInfo->posterPath != nil)
        free(movieInfo->posterPath);
    if (movieInfo->overview != nil)
        free(movieInfo->overview);
    if (movieInfo->releaseDate != nil)
        free(movieInfo->releaseDate);
}

-(long)getMovieId {
    if (self->movieInfo == nil) {
        return 0;
    } else {
        return self->movieInfo->movieId;
    }
}

-(int)getVoteCount {
    if (self->movieInfo == nil) {
        return 0;
    } else {
        return self->movieInfo->voteCount;
    }
}

-(int)getVoteAverage {
    if (self->movieInfo == nil) {
        return 0;
    } else {
        return self->movieInfo->voteAverage;
    }
}

-(NSString*)getTitle {
    if (self->movieInfo == nil || self->movieInfo->title == nil) {
        return nil;
    } else {
        return [NSString stringWithUTF8String:self->movieInfo->title];
    }
}

-(NSString*)getPosterPath {
    if (self->movieInfo == nil || self->movieInfo->posterPath == nil) {
        return nil;
    } else {
        return [NSString stringWithUTF8String:self->movieInfo->posterPath];
    }
}

-(NSString*)getOverview {
    if (self->movieInfo == nil || self->movieInfo->overview == nil) {
        return nil;
    } else {
        return [NSString stringWithUTF8String:self->movieInfo->overview];
    }
}

-(NSString*)getReleaseDate {
    if (self->movieInfo == nil || self->movieInfo->releaseDate == nil) {
        return nil;
    } else {
        return [NSString stringWithUTF8String:self->movieInfo->releaseDate];
    }
}

@end
