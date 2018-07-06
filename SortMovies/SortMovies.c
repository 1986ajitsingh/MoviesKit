//
//  SortMovies.c
//  SortMovies
//
//  Created by Ajit Singh on 05/07/18.
//  Copyright © 2018 Assignment. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#import "SortMovies.h"

// Sorting movies based on the ratings (vote average)
int compareMovies(const void *ptr1, const void *ptr2) {
    MovieInfo **movie1 = (MovieInfo **)ptr1;
    MovieInfo **movie2 = (MovieInfo **)ptr2;
    if((*movie1)->voteAverage > (*movie2)->voteAverage) {
        // <0 movie1 goes before movie2
        return -1;
    } else {
        // <0 movie2 goes before movie1
        return 1;
    }
}

void sortMovies(MovieInfo ** movies, unsigned long moviesCount) {
    if (movies == NULL)
        return;
    
    // Complexity of qsort (although not certain but) is said to be O(n Logn)
    qsort(movies, moviesCount, sizeof(MovieInfo*), compareMovies);
}

