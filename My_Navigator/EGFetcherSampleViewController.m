//
//  EGFetcherSampleViewController.m
//  My_Navigator
//
//  Created by Евгений Гостев on 15.02.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "EGFetcherSampleViewController.h"
#import <GooglePlaces/GooglePlaces.h>
#import "CLLocation+EGCheckCLLocationCoordinate2D.h"
#import "EGSamplesPlaces.h"
#import "EGMarkers.h"


@interface EGFetcherSampleViewController ()

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchTextFieldConstraintTop;

@end


@implementation EGFetcherSampleViewController {
    NSArray* _arrayPlace;
    EGSamplesPlaces* _samplesPlaces;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _samplesPlaces = [EGSamplesPlaces sharedSamplesPlaces];
    _arrayPlace = [NSArray array];
    [_searchTextField becomeFirstResponder];
    if (_locationType == EGOriginLocationType) {
        _searchTextFieldConstraintTop.constant = 15;
    } else if (_locationType == EGDestinationLocationType) {
        _searchTextFieldConstraintTop.constant = 65;
    }
}

#pragma mark - UItextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [_samplesPlaces setRequest:newString];
    _arrayPlace = [_samplesPlaces getSamplesPlaces];
    [_tableView reloadData];
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _isMyLocationEnabled ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _isMyLocationEnabled && !section ? 1 : [_arrayPlace count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* indentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentifier];
    }
    if ([CLLocation EGCLLocationNoNullCoordinate:self.myLocation] && !indexPath.section) {
        cell.textLabel.text = @"Мое местоположение";
        cell.imageView.image = [UIImage imageNamed:@"My Location.png"];
    } else {
        GMSPlace* place = _arrayPlace[indexPath.row];
        cell.textLabel.text = place.name;
        cell.detailTextLabel.text = place.formattedAddress;
        cell.imageView.image = [UIImage imageNamed:@"location.png"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GMSPlace* place;
    if ([CLLocation EGCLLocationNoNullCoordinate:self.myLocation] && !indexPath.section) {
        place = nil;
    } else {
        place = _arrayPlace[indexPath.row];
    }
    [self _createMarkerFromPlace:place];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.f;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Metods

- (void)_createMarkerFromPlace:(GMSPlace *)place {
    EGMarkers* markers = [[EGMarkers alloc] initWithPlace:place
                                            andMyLocation:self.myLocation];
    GMSMarker* marker = [markers marker];
    [self.delegate autocompleteWithMarker:marker
                          andLocationType:_locationType];
}

@end
