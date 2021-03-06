//
//  ViewController.m
//  InClass05
//
//  Created by student on 7/9/15.
//  Copyright (c) 2015 student. All rights reserved.
//

#import "ViewController.h"
#import "PhotoDisplayViewController.h"
#import "UIImageView+WebCache.h"
#import "PhotoDetailCellTableViewCell.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchField;
@property (strong, nonatomic) NSMutableArray* photos;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
static NSString* url = @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=072e602ec22ea148cf67859244be122e&extras=url_m&per_page=20&format=json&nojsoncallback=1&text=";

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.photos.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PhotoDetailCellTableViewCell* cell = (PhotoDetailCellTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if(!cell){
        cell = [[PhotoDetailCellTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"myCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UILabel* title = (UILabel*)[cell textView];
    title.text = [self.photos[indexPath.row] valueForKey:@"title"];
    [(UIImageView*)[cell imageView] sd_setImageWithURL: [NSURL URLWithString:[self.photos[indexPath.row] valueForKey:@"url_m" ] ]];
    //[self loadPhotoWithUrl:[self.photos[indexPath.row] valueForKey:@"url_m"] InCell:cell];
    return cell;
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"inside search bar");
    [searchBar resignFirstResponder];
    [self searchBtnClicked:searchBar.text];
}
- (void)searchBtnClicked:(NSString*)txt {
    [[self activityIndicator] startAnimating];
    NSString *searchTxt = txt;
    NSURLRequest *request  = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url, [searchTxt stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if(error){
                        NSLog(@"error : %@", error);
                        return ;
                    }
                    NSLog(@"inside completion handler");
                    NSMutableDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:&error];
                    if(error){
                        NSLog(@"error in json parsing");
                        return;
                    }
                    NSLog(@"data=%@",dataDict);
                    self.photos = [dataDict valueForKeyPath:@"photos.photo"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [(UITableView*)[self.view viewWithTag:1000] reloadData];
                        [[self activityIndicator] stopAnimating];
                    });
                    
                }]
     resume];
}

-(void) loadPhotoWithUrl:(NSString *)url InCell:(UITableViewCell*) cell {
    NSURLRequest *request  = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", url]]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if(error){
                        NSLog(@"error : %@", error);
                        return ;
                    }
                    UIImage *image = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImageView *imgView  = (UIImageView*)[cell viewWithTag:200];
                        imgView.image = image;
                    });
                    
                }] resume];

}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ViewController* dvc = segue.destinationViewController;
    if([dvc isKindOfClass: [PhotoDisplayViewController class ]]){
        PhotoDisplayViewController* pvc = (PhotoDisplayViewController*) dvc;
        UITableViewCell * cell = (UITableViewCell *) sender;
        long row = [(UITableView*)[self.view viewWithTag:1000] indexPathForCell:cell].row;
        NSString* url = [self.photos[row] valueForKey:@"url_m"];
        pvc.url = url;
    }
}
-(IBAction)doneDetail:(UIStoryboardSegue*) sender{
    NSLog(@"inside done detail");
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}
@end
