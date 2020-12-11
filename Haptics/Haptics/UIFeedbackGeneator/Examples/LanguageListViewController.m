//
//  LanguageListViewController.m
//  MeiQi
//
//  Created by 树妖 on 2019/5/7.
//  Copyright © 2019 ZYK. All rights reserved.
//

#import "LanguageListViewController.h"
#import "FeedbackGeneatorUtil.h"
#import "LanguageCell.h"

@interface LanguageListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *titles;

/** 选中Cell的Index */
@property (nonatomic, assign) NSInteger selectedIndex;

/** 当前语言的Index */
@property (nonatomic, assign) NSInteger currentLanguageIndex;

@end

@implementation LanguageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupData];
    [self setupUI];
}

- (void)setupData {
    self.titles = @[
        @[NSLocalizedString(@"English", nil),
          NSLocalizedString(@"Chinese (Impact Feedback)", nil),
          NSLocalizedString(@"Korean", nil)]
    ];

    self.selectedIndex = 0;
    self.currentLanguageIndex = self.selectedIndex;
}

- (void)setupUI {
    self.title = @"UIImpactFeedbackStyleLight";

    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"LanguageCell" bundle:nil] forCellReuseIdentifier:LanguageCellID];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveEvent)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}


#pragma mark - Events

/** 保存语言设置 */
- (void)saveEvent {
    
}


#pragma mark - UITableViewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray *)self.titles[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSString *title = self.titles[section][row];
    
    LanguageCell *cell = [tableView dequeueReusableCellWithIdentifier:LanguageCellID forIndexPath:indexPath];
    cell.title = title;
    if (self.selectedIndex == row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LanguageCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectedIndex == indexPath.row) {
        return;
    }
    
    if (self.currentLanguageIndex == indexPath.row) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if (indexPath.row == 1) {
            // MARK: -------- UIImpactFeedbackGenerator 的使用 --------
            [FeedbackGeneatorUtil generateImpactFeedbackWithStyle:UIImpactFeedbackStyleLight];
        }
    }
    
    self.selectedIndex = indexPath.row;
    
    [tableView reloadData];
}

@end
