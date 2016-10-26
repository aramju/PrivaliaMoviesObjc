//
//  MovieCellTableViewCell.h
//  PrivaliaMoviesObjc
//
//  Created by Aram Julhakyan on 21/10/16.
//  Copyright © 2016 ZenBrains Studio S.L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteImageView.h"
@interface MovieCellTableViewCell : UITableViewCell


@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *yearLabel;
@property (nonatomic, strong) IBOutlet UILabel *overviewLabel;
@property (nonatomic, strong) IBOutlet RemoteImageView *movieImage;

@end
