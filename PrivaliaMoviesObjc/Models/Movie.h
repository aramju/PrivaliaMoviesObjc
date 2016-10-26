//
//  Movie.h
//  PrivaliaMoviesObjc
//
//  Created by Aram Julhakyan on 22/10/16.
//  Copyright © 2016 ZenBrains Studio S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *year;
@property (nonatomic, strong)NSString *overview;
@property (nonatomic, strong)NSString *posterURL;

@end
