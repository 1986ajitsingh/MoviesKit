//
//  MovieInfo.h
//  FilterMovies
//
//  Created by Ajit Singh on 05/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#ifndef MovieInfo_h
#define MovieInfo_h

typedef struct movieInfo {
    long movieId;
    int voteCount;
    int voteAverage;
    char* title;
    char* posterPath;
    char* overview;
    char* releaseDate;
} MovieInfo;

#endif /* MovieInfo_h */
