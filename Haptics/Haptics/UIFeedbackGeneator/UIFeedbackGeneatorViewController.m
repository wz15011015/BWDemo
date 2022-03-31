//
//  UIFeedbackGeneatorViewController.m
//  Haptics
//
//  Created by hadlinks on 2020/11/23.
//

#import "UIFeedbackGeneatorViewController.h"
#import "FeedbackGeneratorUtil.h"
#import "LanguageListViewController.h"
#import "AddHandsetViewController.h"
#import "EditDeviceViewController.h"

static NSString *const CellID = @"FeedbackCellIdentifier";

@interface UIFeedbackGeneatorViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation UIFeedbackGeneatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.titles = @[
        @"UIImpactFeedbackStyleLight",
        @"UIImpactFeedbackStyleMedium",
        @"UIImpactFeedbackStyleHeavy",
        @"UIImpactFeedbackStyleSoft (iOS 13.0)",
        @"UIImpactFeedbackStyleRigid (iOS 13.0)"
    ];
    
    self.title = @"UIFeedbackGeneator";
    
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
        [FeedbackGeneratorUtil generateImpactFeedbackWithStyle:UIImpactFeedbackStyleLight];
        
        LanguageListViewController *vc = [[LanguageListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (index == 1) {
        [FeedbackGeneratorUtil generateImpactFeedbackWithStyle:UIImpactFeedbackStyleMedium];
        
        AddHandsetViewController *vc = [[AddHandsetViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (index == 2) {
        [FeedbackGeneratorUtil generateImpactFeedbackWithStyle:UIImpactFeedbackStyleHeavy];
        
        EditDeviceViewController *vc = [[EditDeviceViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (index == 3) {
        if (@available(iOS 13.0, *)) {
            [FeedbackGeneratorUtil generateImpactFeedbackWithStyle:UIImpactFeedbackStyleSoft];
        }
        
    } else if (index == 4) {
        if (@available(iOS 13.0, *)) {
            [FeedbackGeneratorUtil generateImpactFeedbackWithStyle:UIImpactFeedbackStyleRigid];
        }
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
