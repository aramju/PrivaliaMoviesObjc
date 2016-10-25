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
#import "Movie.h"

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
        
        Movie *movie = [movieManager.movies objectAtIndex:indexPath.row];
        
        cell.titleLabel.text = movie.title;
        cell.yearLabel.text = movie.year;
        cell.overviewLabel.text = movie.overview;
        
        cell.movieImage.image = nil;
        if (movie.posterURL){
            [cell.movieImage loadImageURL:[NSURL URLWithString:[movie.posterURL stringByAddingPercentEscapesUsingEncoding:
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
