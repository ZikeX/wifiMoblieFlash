//
//  ViewController.m
//  HailyCloudMemery
//
//  Created by 易海 on 16/5/23.
//  Copyright © 2016年 易海. All rights reserved.
//

#import "ViewController.h"
#import "FileTableViewCell.h"
#import "WifiViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;


@property (nonatomic, strong) NSMutableArray *files;
@end

@implementation ViewController

- (NSMutableArray *)files
{
    if (!_files) {
        _files = ({
            NSMutableArray *array = [NSMutableArray new];
            array;
        });
    }
    return _files;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkFileLists];
    [self.tableview registerNib:[UINib nibWithNibName:@"FileTableViewCell" bundle:nil] forCellReuseIdentifier:@"FileTableViewCellIdentifer"];
    self.tableView.rowHeight = 60.f;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.title = @"文件列表";
    self.navigationItem.rightBarButtonItem = [self rightItem];
    // Do any additional setup after loading the view, typically from a nib.
}

- (UIBarButtonItem *)rightItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"传输" style:UIBarButtonItemStyleDone target:self action:@selector(showUploadView)];
    return item;
}

- (void)showUploadView
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    WifiViewController *wifi = (WifiViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"WifiViewController"];
    [self.navigationController pushViewController:wifi animated:YES];
    wifi.back = ^()
    {
        [self checkFileLists];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isDirectory:(NSString *)fileName superPath:(NSString *)path
{
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory])
    {
        NSLog(@"路径不存在 %@",filePath);
    }
    
    return isDirectory;
}

//搜索文件列表
- (void)checkFileLists
{
    [self.files removeAllObjects];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    
    
    BOOL isDir = NO;
    if ([defaultManager fileExistsAtPath:diskPath isDirectory:&isDir])
    {
        if (!isDir)
        {
            NSLog(@"谁吃饱了撑得弄这个");
            [defaultManager removeItemAtPath:diskPath error:NULL];
            if ([defaultManager createDirectoryAtPath:diskPath withIntermediateDirectories:YES attributes:nil error:NULL])
            {
                NSLog(@"创建文件夹成功");
            }
        }
    }
    else
    {
        if ([defaultManager createDirectoryAtPath:diskPath withIntermediateDirectories:YES attributes:nil error:NULL])
        {
            NSLog(@"创建文件夹成功");
        }
    }
    
    
    
    NSArray *list = [defaultManager contentsOfDirectoryAtPath:diskPath error:NULL];
    
    for (uint i = 0; i < list.count; i ++) {
        NSString *file = list[i];
        BOOL isDirectory = [self isDirectory:file superPath:diskPath];
        long long fileSize = 0;
        if (!isDirectory)
        {
            fileSize += [[NSFileManager defaultManager] attributesOfItemAtPath:[diskPath stringByAppendingPathComponent:file] error:NULL].fileSize;
        }
        NSDictionary *fileObj = @{@"name":file, @"isDirectory":[NSNumber numberWithBool:isDirectory], @"size":[NSNumber numberWithLong:fileSize]};
        [self.files addObject:fileObj];
    }
    
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"FileTableViewCellIdentifer";
    FileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = (FileTableViewCell *)[[NSBundle mainBundle] loadNibNamed:@"FileTableViewCell" owner:nil options:nil][0];
    }
    
    cell.fileData = self.files[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return   UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete)
    {
        
        //删除对应文件
        NSDictionary *fileObj = self.files[indexPath.row];
        NSString *file = fileObj[@"name"];
        NSString *filePath = [diskPath stringByAppendingPathComponent:file];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
            [self.files  removeObjectAtIndex:[indexPath row]];  //删除数组里的数据
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
