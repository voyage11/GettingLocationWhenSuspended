//
//  LocationViewController.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import "LocationViewController.h"

@interface LocationViewController ()

@end

@implementation LocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
}

-(void)reloadData
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, @"LocationArray.plist"];
    
    savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
    
    if (savedProfile)
    {
        //Sort
        locationArray = [[savedProfile objectForKey:@"LocationArray"] sortedArrayUsingDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"Time" ascending:0]]];
        
        if (_modeSeg.selectedSegmentIndex == 1)
        {
            NSMutableArray *temp = @[].mutableCopy;
            for (NSDictionary *dic in locationArray)
            {
                if ([dic objectForKey:@"Accuracy"]) [temp addObject:dic];
            }
            locationArray = temp;
        }
    }
    
    [self.tableView  reloadData];
}

- (IBAction)modeDidChanged:(UISegmentedControl *)sender
{
    [self reloadData];
}

#pragma mark - tableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return locationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *dic = [locationArray objectAtIndex:indexPath.row];
    
    NSString *appState = [NSString stringWithFormat:@"App State : %@",  [dic[@"AppState"] stringByReplacingOccurrencesOfString:@"UIApplicationState" withString:@""] ];
    NSDate *date = dic[@"Time"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm";
    NSString *time = [dateFormatter stringFromDate:date];
    
    if ([dic objectForKey:@"Accuracy"])
    {
        NSString *accuracy = [NSString stringWithFormat:@"Accuracy : %@",dic[@"Accuracy"]];
        NSString *location = [NSString stringWithFormat:@"Location : %.06f , %.06f",[dic[@"Latitude"] floatValue],[dic[@"Longitude"] floatValue]];
        NSString *addFromResum = [NSString stringWithFormat:@"Add From Resume : %@",[[dic objectForKey:@"AddFromResume"] boolValue] ? @"YES" : @"NO"];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",appState,addFromResum,accuracy,location,time];
    }
    else if ([dic objectForKey:@"Resume"])
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@\n\n",appState,dic[@"Resume"],time];
    }
    else
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@\n\n",appState,dic[@"applicationStatus"],time];
    }
    
    return cell;
}

@end
