//
//  SecondViewController.m
//  PrivaliaMoviesObjc
//
//  Created by Aram Julhakyan on 21/10/16.
//  Copyright © 2016 ZenBrains Studio S.L. All rights reserved.
//

#import "SearchViewController.h"
#import "MovieCellTableViewCell.h"
#import "MBProgressHUD.h"
#import "Movie.h"



@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(_searchBar.searchTextPositionAdjustment.horizontal*1.5, self.searchBar.frame.size.height*0.5);
    [self.searchBar addSubview: spinner];
    
    
    
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200;
    movieManager = [[MovieManager alloc] init];
    movieManager.delegate = self;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [spinner startAnimating];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadSearch) object:nil];
    [self performSelector:@selector(loadSearch) withObject:nil afterDelay:0.5];
    
    
}

-(void)loadSearch{
    [self loadMoviesForPage:1 andSearchTerm:self.searchBar.text];
}


-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    
}


-(void)loadMoviesForPage:(NSInteger)page andSearchTerm:(NSString *)term{
    
    [movieManager loadMoviesForPage:page andSearchTerm:term];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)moviesDidLoad{
    [spinner stopAnimating];
    [self.tableView reloadData];
}

-(void)errorLoadingMovies{
    [spinner stopAnimating];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error obtaining movies "
                                                                   message:@"There were an error connecting to the movies server."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
     
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchBar.text.length==0)
        return 0;
    
    //If we've loaded all movies
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
        
        Movie *movie = [movieManager.movies objectAtIndex:indexPath.row];
        
        
        
        cell.titleLabel.text = movie.title ? movie.title : @" ";
        cell.yearLabel.text = movie.year ? movie.year : @" ";
        cell.overviewLabel.text = movie.overview ? movie.overview : @" ";
        
        cell.movieImage.image = nil;
        if (movie.posterURL){
            
            [cell.movieImage loadImageURL:[NSURL URLWithString:movie.posterURL] withCompleteBlock:^(UIImage *image) {
                NSLog(@"Loaded");
            } withErrorBlock:^(NSError *error) {
                NSLog(@"ERROR LOADING");
            }];
        }else{
            cell.movieImage.image = [UIImage imageNamed:@"noimage"];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == movieManager.movies.count - 1 && movieManager.movies.count != movieManager.totalItems) {
        [self loadMoviesForPage:movieManager.currentPage+1 andSearchTerm:self.searchBar.text];
    }
}


@end
