//
//  Movie.h
//  MoviesKit
//
//  Created by Ajit Singh on 04/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMovie.h"
#import "../../SortMovies/MovieInfo.h"

@interface Movie : NSObject <IMovie>

-(id)initWithMovieInfo:(MovieInfo*)movieInfo;

@end
