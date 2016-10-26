//
//  SecondViewController.h
//  PrivaliaMoviesObjc
//
//  Created by Aram Julhakyan on 21/10/16.
//  Copyright © 2016 ZenBrains Studio S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieManager.h"

@interface SearchViewController : UITableViewController <UISearchBarDelegate>{
    MovieManager *movieManager;
    UIActivityIndicatorView *spinner;
}

@property (nonnull, strong)IBOutlet UISearchBar *searchBar;


@end

