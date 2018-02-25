//
//  EGDestination.m
//  My_Navigator
//
//  Created by Евгений Гостев on 24.02.2018.
//  Copyright © 2018 Евгений Гостев. All rights reserved.
//

#import "EGDestinationTableView.h"

@implementation EGDestinationTableView {
    NSArray* _array;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.destinationTableView.delegate = self;
        _array = @[@"Москва", @"Подольск", @"Домодедово", @"Пенза", @"Видное", @"Молоково"];
    }
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_array count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* indentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
    }
    
    cell.textLabel.text = _array[indexPath.row];
    return cell;
}


@end
