//
//  EGFetcherSampleViewController.h
//  My_Navigator
//
//  Created by Евгений Гостев on 15.02.18.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlaces/GooglePlaces.h>

@protocol EGFetcherSampleViewControllerDelegate <NSObject>

- (void)autocompleteWithPlace:(GMSPlace *)place nameLocation:(NSString*) name andIsSelectedOriginLocation:(BOOL) isSelectedOriginLocation;

@end

    
@interface EGFetcherSampleViewController : UITableViewController

@property (assign, nonatomic) BOOL isMyLocationEnabled;
@property (assign, nonatomic) BOOL isSelectedOriginLocation;
@property (weak, nonatomic) IBOutlet UISearchBar *textSearchBar;

@property (weak, nonatomic) id <EGFetcherSampleViewControllerDelegate> delegate;

@end
