//
//  TestCategories.h
//  MoviesKit
//
//  Created by Globallogic on 07/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#ifndef TestCategories_h
#define TestCategories_h

#import "SearchMoviesOperation.h"

@interface SearchMoviesOperation (Testing)
@property(nonatomic, strong) NSString *queryString;
@property(nonatomic, strong) NSString *year;
@property(nonatomic, strong) NSString *page;
@property(nonatomic, strong) NSString *apiKey;
@end

#endif /* TestCategories_h */
