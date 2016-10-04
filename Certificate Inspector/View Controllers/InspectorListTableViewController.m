//
//  InspectorListTableViewController.m
//  Certificate Inspector
//
//  GPLv3 License
//  Copyright (c) 2016 Ian Spence
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software Foundation,
//  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

#import "InspectorListTableViewController.h"

@interface InspectorListTableViewController ()

@property (strong, nonatomic) NSArray * items;
@property (strong, nonatomic) NSString * viewTitle;

@end

@implementation InspectorListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.viewTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setList:(NSArray *)array title:(NSString *)title {
    _items = array;
    _viewTitle = title;
}

#pragma mark - Table view data source

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:cell.detailTextLabel.text];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
    
    cell.textLabel.text = self.items[indexPath.row];
    
    return cell;
}

@end
