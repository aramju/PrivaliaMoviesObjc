//
//  MoviesViewController.m
//  PrivaliaMoviesObjc
//
//  Created by Aram Julhakyan on 21/10/16.
//  Copyright © 2016 ZenBrains Studio S.L. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCellTableViewCell.h"
#import "MBProgressHUD.h"

#define MOVIES_IN_PAGE 10

@interface MoviesViewController ()



@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
    
    
    movieManager = [[MovieManager alloc] init];
    movieManager.delegate = self;
    
    [self loadMoviesForPage:1];
    
    
   
}



-(void)loadMoviesForPage:(NSInteger)page{
    if (page==1){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.label.text = @"Loading movies";
    }
    
    [movieManager loadMoviesForPage:page];
}

-(void)moviesDidLoad{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.tableView reloadData];
}

-(void)errorLoadingMovies{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error obtaining movies "
                                                                   message:@"There were an error connecting to the movies server."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (movieManager.currentPage == movieManager.totalPages || movieManager.totalItems == movieManager.movies.count) {
        return movieManager.movies.count;
    }
    return movieManager.movies.count + 1;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == movieManager.movies.count) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadCell" forIndexPath:indexPath];
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:100];
        [activityIndicator startAnimating];
        return cell;
        
    }else{
    
        MovieCellTableViewCell *cell = (MovieCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        NSDictionary *movie = [movieManager getMovieInfoForIndex:indexPath.row];
        
        cell.titleLabel.text = [movie objectForKey:@"title"];
        cell.yearLabel.text =[movie objectForKey:@"year"];
        cell.overviewLabel.text = [movie objectForKey:@"overview"];
        
        cell.movieImage.image = nil;
        if ([movie objectForKey:@"posterURL"]){
            [cell.movieImage loadImageURL:[NSURL URLWithString:[[movie objectForKey:@"posterURL"]  stringByAddingPercentEscapesUsingEncoding:
                                                     NSUTF8StringEncoding]] withCompleteBlock:^(UIImage *image) {
                
            } withErrorBlock:^(NSError *error) {
                
            }];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == movieManager.movies.count - 1 ) {
        [self loadMoviesForPage:movieManager.currentPage+1];
    }
}


@end
