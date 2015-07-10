//
//  PhotoDetailCellTableViewCell.m
//  InClass05
//
//  Created by student on 7/10/15.
//  Copyright (c) 2015 student. All rights reserved.
//

#import "PhotoDetailCellTableViewCell.h"

@implementation PhotoDetailCellTableViewCell

@synthesize imageView;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)init{
    self = [super init];
    if(self){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

@end
