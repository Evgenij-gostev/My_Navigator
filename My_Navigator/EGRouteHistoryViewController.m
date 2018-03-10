//
//  EGRouteHistoryViewController.m
//  My_Navigator
//
//  Created by Евгений Гостев on 04.03.2018.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "EGRouteHistoryViewController.h"
#import "EGRouteHistory.h"
#import "Realm.h"


@implementation EGRouteHistoryViewController {
    NSArray * _arrayRouteHistory;
    NSDateFormatter* _dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    
    RLMResults<EGRouteHistory* >* routeHistory = [EGRouteHistory allObjects];
   _arrayRouteHistory = [routeHistory valueForKey:@"self"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 1 && [_arrayRouteHistory count] != 0 ? 1 : [_arrayRouteHistory count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* indentifier = @"Cell";
    static NSString* indentifierDelete = @"CellDelete";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentifier];
    }
    if (indexPath.section == 0) {
        EGRouteHistory* routeHistory = _arrayRouteHistory[indexPath.row];
        cell.textLabel.text = routeHistory.name;
        cell.detailTextLabel.text = [_dateFormatter stringFromDate:routeHistory.date];
    } else if (indexPath.section == 1) {
        UITableViewCell* cellDelete =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifierDelete];
        cellDelete.textLabel.text = @"Очистить историю";
        cellDelete.textLabel.textColor = [UIColor redColor];
        return cellDelete;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        EGRouteHistory* routeHistory = _arrayRouteHistory[indexPath.row];
        [self _loadRouteHistory:routeHistory];
    } else if (indexPath.section == 1) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm deleteAllObjects];
        [realm commitWriteTransaction];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private metods

- (void)_loadRouteHistory:(EGRouteHistory*) routeHistory {
    GMSMarker* originMarker = [routeHistory getOriginMarker];
    GMSMarker* destinationMarker = [routeHistory getDestinationMarker];
    [self.delegate loadingRouteFromHistoryWithOriginMarker:originMarker destinationMarker:destinationMarker];
}

@end
