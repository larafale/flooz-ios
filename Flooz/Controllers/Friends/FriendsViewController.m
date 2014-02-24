//
//  FriendsViewController.m
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendsViewController.h"

#import "FriendCell.h"

@interface FriendsViewController (){
    NSArray *friendsRequest;
    NSArray *friends;
}

@end

@implementation FriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        friendsRequest = @[];
        friends = @[];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    if(!animated){
        [[Flooz sharedInstance] updateCurrentUserWithSuccess:^() {
            friendsRequest = [[[Flooz sharedInstance] currentUser] friendsRequest];
            friends = [[[Flooz sharedInstance] currentUser] friends];
            
            [_tableView reloadData];
            [_tableView setContentOffset:CGPointZero animated:YES];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // WARNING Hack contraintes ne fonctionnent pas
    _tableView.frame = CGRectMakeWithSize(self.view.frame.size);
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return [friendsRequest count];
    }
    return [friends count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    FLUser *friend = [friends objectAtIndex:indexPath.row];
    return [FriendCell height];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        static NSString *cellIdentifier = @"FriendRequestCell";
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(!cell){
            cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            //        cell.delegate = self;
        }
        
        FLFriendRequest *friendRequest = [friendsRequest objectAtIndex:indexPath.row];
//        [cell setFriend:friend];
        
        return cell;
    }
    else{
        static NSString *cellIdentifier = @"FriendCell";
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(!cell){
            cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            //        cell.delegate = self;
        }
        
        FLUser *friend = [friends objectAtIndex:indexPath.row];
        [cell setFriend:friend];
        
        return cell;
    }
}

@end
