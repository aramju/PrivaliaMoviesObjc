//
//  MovieManager.h
//  PrivaliaMoviesObjc
//
//  Created by Aram Julhakyan on 22/10/16.
//  Copyright © 2016 ZenBrains Studio S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieManager : NSObject

@property (nonatomic, strong)NSString *lastSearchTerm;

@property (nonatomic, strong)NSMutableArray *movies;
@property (nonatomic, assign)id delegate;

@property (strong)NSMutableArray *tasks;

//@property (nonatomic, strong)NSURLSessionDataTask *connectinoTask;



@property (nonatomic, assign)NSInteger currentPage;
@property (nonatomic, assign)NSInteger totalPages;
@property (nonatomic, assign)NSInteger totalItems;

//+ (MovieManager *)sharedManager;

//Loads the list of popular movies given the page
- (void)loadMoviesForPage:(NSInteger)page;

//Loads the list of movies given the page and search term
- (void)loadMoviesForPage:(NSInteger)page andSearchTerm:(NSString *)term;

-(NSDictionary *)getMovieInfoForIndex:(NSInteger)index;



@end

@protocol MovieManagerDelegate <NSObject>

@optional
-(void)moviesDidLoad;
-(void)errorLoadingMovies;

@end
