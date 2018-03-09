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

@interface EGRouteHistoryViewController ()

@end

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arrayRouteHistory count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* indentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentifier];
    }
    EGRouteHistory* routeHistory = _arrayRouteHistory[indexPath.row];
    cell.textLabel.text = routeHistory.name;
    cell.detailTextLabel.text = [_dateFormatter stringFromDate:routeHistory.date];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EGRouteHistory* routeHistory = _arrayRouteHistory[indexPath.row];
    [self loadRouteHistory:routeHistory];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private metods

- (void)loadRouteHistory:(EGRouteHistory*) routeHistory {
    GMSMarker* originMarker = [routeHistory getOriginMarker];
    GMSMarker* destinationMarker = [routeHistory getDestinationMarker];
    [self.delegate loadingRouteFromHistoryWithOriginMarker:originMarker destinationMarker:destinationMarker];
}

@end
