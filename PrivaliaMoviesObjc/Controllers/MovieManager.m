//
//  MovieManager.m
//  PrivaliaMoviesObjc
//
//  Created by Aram Julhakyan on 22/10/16.
//  Copyright © 2016 ZenBrains Studio S.L. All rights reserved.
//

#define IMAGE_API_KEY @"75a323422f6e0e9fc51b835782540a4f"
#define IMAGE_API_URL @"http://webservice.fanart.tv/v3/movies/%@?api_key=%@"
#define WS_API_KEY @"019a13b1881ae971f91295efc7fdecfa48b32c2a69fe6dd03180ff59289452b8"
#define WS_API_URL @"http://api.trakt.tv/movies/popular?extended=full&page=%d"
#define WS_SEARCH_API_URL @"http://api.trakt.tv/movies/popular?extended=full&fields=title&type=movie&page=%d&query=%@"


#import "MovieManager.h"
#import "Movie.h"


@implementation MovieManager

-(id)init{
    self = [super init];
    
    if (self){
        self.movies = [[NSMutableArray alloc] initWithCapacity:10];
        self.tasks = [[NSMutableArray alloc] initWithCapacity:10];
        
    }
    
    return self;
}

-(NSString *)obtainPosterURLForMovie:(NSString *)idMovie{
    NSString *imageUrl = [NSString stringWithFormat:IMAGE_API_URL, idMovie, IMAGE_API_KEY];
    NSURL *url = [NSURL URLWithString:imageUrl];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    NSError *error;
    
    NSDictionary *obtainedData;
    
    @try {
        obtainedData = [NSJSONSerialization JSONObjectWithData:imageData
                                                                     options:0
                                                                       error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
    
    if (!obtainedData)
        return nil;
    
    if ([[obtainedData objectForKey:@"status"] isEqualToString:@"error"])
        return nil;
    
    NSArray *posters = [obtainedData objectForKey:@"movieposter"];
    if (posters.count > 0){
        NSDictionary *posterInfo = [posters firstObject] ;
        NSString *posterURL = [[posterInfo objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"/fanart/" withString:@"/preview/"];
        
        return posterURL;
    }
    return nil;
}


-(void)reseatSearchInfo{
    self.lastSearchTerm = nil;
    self.totalItems = 0;
    self.totalPages = 0;
    self.currentPage = 0;
    [self.movies removeAllObjects];
    
    [self.tasks enumerateObjectsUsingBlock:^(NSURLSessionDataTask *taskObj, NSUInteger idx, BOOL *stop) {
        [taskObj cancel]; /// when sending cancel to the task failure: block is going to be called
    }];
     
}

-(void)notifyMoviedDidLoad{
    if (self.delegate && [self.delegate respondsToSelector:@selector(moviesDidLoad)]){
        [self.delegate performSelectorOnMainThread:@selector(moviesDidLoad) withObject:nil waitUntilDone:NO];
    }
}

-(void)notifyError{
    if (self.delegate && [self.delegate respondsToSelector:@selector(errorLoadingMovies)]){
        [self.delegate performSelectorOnMainThread:@selector(errorLoadingMovies) withObject:nil waitUntilDone:NO];
    }
}

-(Movie *)createMovieFromData:(NSDictionary *)d{
    Movie *movie = [[Movie alloc] init];
    
    if ([d objectForKey:@"title"] != [NSNull null])
        movie.title = [d objectForKey:@"title"];
    else
        movie.title = @"Unknown title";
    
    if ([d objectForKey:@"year"] != [NSNull null])
        movie.year = [[d objectForKey:@"year"] stringValue];
    else
        movie.year = @"Unknown";
    
    
    if  ([d objectForKey:@"overview"] !=[NSNull null])
        movie.overview = [d objectForKey:@"overview"];
    else
        movie.overview = @"There are no overview available for this movie.";
    
    
    
    NSDictionary *ids = [d objectForKey:@"ids"];
    NSString *movieId = [ids objectForKey:@"tmdb"];
    
    movie.posterURL = [self obtainPosterURLForMovie:movieId];
    
    return movie;
}

-(void)updatePagesFromResponse:(NSHTTPURLResponse *)resp{
    self.totalItems = [[[resp allHeaderFields ] objectForKey:@"X-Pagination-Item-Count"] integerValue];
    self.totalPages = [[[resp allHeaderFields ] objectForKey:@"X-Pagination-Page-Count"] integerValue];
    self.currentPage = [[[resp allHeaderFields ] objectForKey:@"X-Pagination-Page"] integerValue];
}


- (void)loadMoviesForPage:(NSInteger)page andSearchTerm:(NSString *)term{
    if (!term || term.length==0){
        [self reseatSearchInfo];
        [self notifyMoviedDidLoad];
        return;
    }
    
    //If there is new search term We reseting the search
    if (self.lastSearchTerm && ![self.lastSearchTerm isEqualToString:term]){
        [self reseatSearchInfo];
    }
    self.lastSearchTerm = term;
    
    
    term = [term stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];

    
    NSString *urlString = [NSString stringWithFormat:WS_SEARCH_API_URL, (int)page, term];
    NSURLRequest *request = [self createRequestForURL:urlString];
    
    
    
    [self.tasks enumerateObjectsUsingBlock:^(NSURLSessionDataTask *taskObj, NSUInteger idx, BOOL *stop) {
        [taskObj cancel]; /// cancel the pending task
    }];
    
    /// empty the array of tasks
    [self.tasks removeAllObjects];
    
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    NSURLSessionDataTask *connectinoTask =  [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
       
        if (data.length > 0 && error == nil)
        {
           
            NSArray *obtainedData = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:0
                                                                      error:NULL];
            
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
            [self updatePagesFromResponse:resp];
            
            for (NSDictionary *d in obtainedData){
                Movie *movie = [self createMovieFromData:d];
                [self.movies addObject:movie];
            }
            
            [self notifyMoviedDidLoad];
            
        }else if (error){
            //NSLog(@"******** LocalizedDescr: %@",error.userInfo[@"NSLocalizedDescription"]);
            if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"cancelled"]){
                //Do nothing
            }else{
                [self notifyError];
            }
        }
    }];
    
    
    [connectinoTask resume];
    [self.tasks addObject:connectinoTask];
    
    
}

-(NSDictionary *)getMovieInfoForIndex:(NSInteger)index{
    if (index > self.movies.count-1)
        return nil;
    
    Movie *m = [self.movies objectAtIndex:index];
    
    if (m.posterURL)
        return @{@"title" : m.title, @"year" : m.year, @"overview" : m.overview, @"posterURL" : m.posterURL};
    else
        return @{@"title" : m.title, @"year" : m.year, @"overview" : m.overview};
}


- (void)loadMoviesForPage:(NSInteger)page{
    NSString *urlString = [NSString stringWithFormat:WS_API_URL, (int)page];
    NSURLRequest *request = [self createRequestForURL:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data.length > 0 && error == nil)
        {
            NSArray *obtainedData = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:0
                                                                       error:NULL];
            
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
            [self updatePagesFromResponse:resp];
            
            for (NSDictionary *d in obtainedData){
                Movie *movie = [self createMovieFromData:d];
                [self.movies addObject:movie];
            }
            
            [self notifyMoviedDidLoad];
            
        }else if (error){
            [self notifyError];
        }
    }] resume];
}

-(NSURLRequest *)createRequestForURL:(NSString *)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"2" forHTTPHeaderField:@"trakt-api-version"];
    [request setValue:WS_API_KEY forHTTPHeaderField:@"trakt-api-key"];
    
    return request;
}

/*
+ (MovieManager *)sharedManager {
    static MovieManager *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}*/

@end
