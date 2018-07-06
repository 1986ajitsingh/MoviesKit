//
//  IMovie.h
//  MoviesKit
//
//  Created by Ajit Singh on 04/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#ifndef IMovie_h
#define IMovie_h

@protocol IMovie

@required

-(long)getMovieId;
-(int)getVoteCount;
-(int)getVoteAverage;
-(NSString*)getTitle;
-(NSString*)getPosterPath;
-(NSString*)getOverview;
-(NSString*)getReleaseDate;

@end


#endif /* IMovie_h */
