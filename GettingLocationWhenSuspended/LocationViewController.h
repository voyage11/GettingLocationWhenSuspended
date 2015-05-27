//
//  LocationViewController.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationViewController : UIViewController
{
    NSMutableDictionary *savedProfile;
    NSArray *locationArray;
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *modeSeg;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
