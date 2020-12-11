//
//  CoreHapticsViewController.m
//  Haptics
//
//  Created by hadlinks on 2020/11/24.
//

#import "CoreHapticsViewController.h"
#import "SingleTapViewController.h"
#import "CollisionBasedViewController.h"
#import "ContinuousTransientViewController.h"
#import "CustomHapticViewController.h"

static NSString *const CellID = @"CoreHapticsCellIdentifier";

@interface CoreHapticsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation CoreHapticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titles = @[
        @"Playing a Single-Tap Haptic Pattern",
        @"Playing Collision-Based Haptic Patterns",
        @"Updating Continuous & Transient Haptic Parameters in Real Time",
        @"Playing a Custom Haptic Pattern from a File"
    ];
    
    self.title = @"Core Haptics";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellID];
    [self.view addSubview:self.tableView];
}


#pragma mark - UITableViewDelegate, UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger index = indexPath.row;
    if (index == 0) {
        SingleTapViewController *vc = [[SingleTapViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (index == 1) {
        CollisionBasedViewController *vc = [[CollisionBasedViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (index == 2) {
        ContinuousTransientViewController *vc = [[ContinuousTransientViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (index == 3) {
        CustomHapticViewController *vc = [[CustomHapticViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
