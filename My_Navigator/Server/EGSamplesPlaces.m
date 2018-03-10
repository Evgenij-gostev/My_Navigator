//
//  EGSamplesPlaces.m
//  My_Navigator
//
//  Created by Евгений Гостев on 24.02.2018.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "EGSamplesPlaces.h"
#import <GooglePlaces/GooglePlaces.h>

@interface EGSamplesPlaces () <GMSAutocompleteFetcherDelegate>

@end

@implementation EGSamplesPlaces {
    GMSAutocompleteFetcher* _fetcher;
    GMSPlacesClient* _placesClient;
    NSMutableArray* _arrayPlace;
}

+ (EGSamplesPlaces*)sharedSamplesPlaces {
    static EGSamplesPlaces* samplesPlaces = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        samplesPlaces = [[EGSamplesPlaces alloc] init];
    });
    return samplesPlaces;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _loadComponents];
    }
    return self;
}

#pragma mark - Methods

- (void)_loadComponents {
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterNoFilter;
    // Create the fetcher.
    _fetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:nil
                                                       filter:filter];
    _fetcher.delegate = self;
    _placesClient = [GMSPlacesClient sharedClient];
}

- (void)setRequest:(NSString*) request {
    [_fetcher sourceTextHasChanged:request];
}

- (NSArray*)getSamplesPlaces {
    return [NSArray arrayWithArray:_arrayPlace];
}

#pragma mark - GMSAutocompleteFetcherDelegate

- (void)didAutocompleteWithPredictions:(NSArray *)predictions {
    _arrayPlace = [NSMutableArray array];
    for (GMSAutocompletePrediction *prediction in predictions) {
        [_placesClient lookUpPlaceID:prediction.placeID callback:^(GMSPlace *place, NSError *error) {
            if (error) {
                NSLog(@"Place Details error %@", [error localizedDescription]);
                return;
            }
            if (place) {
                [_arrayPlace addObject:place];
            } else {
                NSLog(@"No place details for %@", prediction.placeID);
            }
        }];
    }
}

- (void)didFailAutocompleteWithError:(NSError *)error {
    NSLog(@"ERROR: %@", error.localizedDescription);
}

@end
