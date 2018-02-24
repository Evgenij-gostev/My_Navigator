//
//  EGFetcherSampleViewController.m
//  My_Navigator
//
//  Created by Евгений Гостев on 15.02.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "EGFetcherSampleViewController.h"


@interface EGFetcherSampleViewController () <GMSAutocompleteFetcherDelegate>

@end

@implementation EGFetcherSampleViewController {
    GMSAutocompleteFetcher* _fetcher;
    GMSPlacesClient* _placesClient;
    NSMutableArray* _arrayPlace;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterNoFilter;
    
    // Create the fetcher.
    _fetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:nil
                                                       filter:filter];
    _fetcher.delegate = self;
    _placesClient = [GMSPlacesClient sharedClient];
}

- (void)textFieldDidChange:(UITextField *)textField {
    _arrayPlace = [NSMutableArray array];
    [_fetcher sourceTextHasChanged:textField.text];
}


#pragma mark - GMSAutocompleteFetcherDelegate

- (void)didAutocompleteWithPredictions:(NSArray *)predictions {
    for (GMSAutocompletePrediction *prediction in predictions) {
        [_placesClient lookUpPlaceID:prediction.placeID callback:^(GMSPlace *place, NSError *error) {
            if (error != nil) {
                NSLog(@"Place Details error %@", [error localizedDescription]);
                return;
            }

            if (place != nil) {
                [_arrayPlace addObject:place];
            } else {
                NSLog(@"No place details for %@", prediction.placeID);
            }
        }];
        [self.tableView reloadData];
    }
}

- (void)didFailAutocompleteWithError:(NSError *)error {
    NSLog(@"ERROR: %@", error.localizedDescription);
}


#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    _arrayPlace = [NSMutableArray array];
    _arrayPlace = nil;
    [_fetcher sourceTextHasChanged:searchText];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isMyLocationEnabled) {
        return 2;
    } else {
       return 1;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isMyLocationEnabled && section == 0) {
        return 1;
    } else {
        return [_arrayPlace count];
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* indentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
    }

    if (self.isMyLocationEnabled && indexPath.section == 0) {
        cell.textLabel.text = @"мое местоположение";
        cell.imageView.image = [UIImage imageNamed:@"My Location.png"];
    } else {
        GMSPlace* place = _arrayPlace[indexPath.row];
        NSLog(@"place: %@", place.name);
        cell.textLabel.text = place.name;
        cell.imageView.image = [UIImage imageNamed:@"location.png"];
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GMSPlace* place = nil;
    if (self.isMyLocationEnabled && indexPath.section == 0) {
        place = nil;
    } else {
        place = _arrayPlace[indexPath.row];
    }
    [self.delegate autocompleteWithPlace:place
             andIsSelectedOriginLocation:self.isSelectedOriginLocation];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
