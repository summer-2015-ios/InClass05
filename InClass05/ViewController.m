//
//  ViewController.m
//  InClass05
//
//  Created by student on 7/9/15.
//  Copyright (c) 2015 student. All rights reserved.
//

#import "ViewController.h"
#import "PhotoDisplayViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) NSMutableArray* photos;
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
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    UILabel* title = (UILabel*)[cell viewWithTag:100];
    title.text = [self.photos[indexPath.row] valueForKey:@"title"];
    [self loadPhotoWithUrl:[self.photos[indexPath.row] valueForKey:@"url_m"] InCell:cell];
    return cell;
}
- (IBAction)searchBtnClicked:(id)sender {
    NSString *searchTxt = self.searchField.text;
    NSURLRequest *request  = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url, searchTxt]]];
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
                    });
                    
                }] resume];
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
@end
