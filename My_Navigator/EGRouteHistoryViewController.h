//
//  EGRouteHistoryViewController.h
//  My_Navigator
//
//  Created by Евгений Гостев on 04.03.2018.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>



@protocol EGRouteHistoryViewControllerDelegate <NSObject>

- (void)loadingRouteFromHistoryWithOriginMarker:(GMSMarker*)originMarker destinationMarker:(GMSMarker*)destinationMarker;

@end



@interface EGRouteHistoryViewController : UIViewController

@property (weak, nonatomic) id <EGRouteHistoryViewControllerDelegate> delegate;

@end
