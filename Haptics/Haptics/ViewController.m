//
//  ViewController.m
//  Haptics
//
//  Created by hadlinks on 2020/11/23.
//

#import "ViewController.h"
#import "UIFeedbackGeneatorViewController.h"
#import "CoreHapticsViewController.h"

static NSString *const CellID = @"CellIdentifier";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Haptics";
    
    self.titles = @[@"UIFeedbackGeneator", @"Core Haptics"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellID];
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
        UIFeedbackGeneatorViewController *vc = [[UIFeedbackGeneatorViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (index == 1) {
        CoreHapticsViewController *vc = [[CoreHapticsViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
