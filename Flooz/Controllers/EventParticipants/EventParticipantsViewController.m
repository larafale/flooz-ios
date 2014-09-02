//
//  EventParticipantsViewController.m
//  Flooz
//
//  Created by jonathan on 2/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventParticipantsViewController.h"

#import "EventParticipantCell.h"
#import "FriendPickerViewController.h"

@interface EventParticipantsViewController (){
    FLEvent *_event;
}

@end

@implementation EventParticipantsViewController

- (id)initWithEvent:(FLEvent *)event
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_EVENT_PARTICIPANTS", nil);
        _event = event;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[self navigationController] navigationBar] setHidden:NO];
    
    [_tableView reloadData];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return nil;
    }
    
    return [NSString stringWithFormat:@"%ld %@", (unsigned long)[[_event participants] count], NSLocalizedString(@"EVENT_PARTICIPANTS_S", nil)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 0;
    }
    
    return 28;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(tableView.frame), [self tableView:tableView heightForHeaderInSection:section])];
    
    view.backgroundColor = [UIColor customBackground];
    
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 0, CGRectGetHeight(view.frame))];
        
        label.textColor = [UIColor customBlue];
        
        label.font = [UIFont customContentRegular:14];
        label.text = [self tableView:tableView titleForHeaderInSection:section];
        [label setWidthToFit];
        
        [view addSubview:label];
    }
    
    {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame), CGRectGetWidth(view.frame), 1)];
        
        separator.backgroundColor = [UIColor customSeparator];
        
        [view addSubview:separator];
    }
    
    return view;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }
    
    return [[_event participants] count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if([_event canInvite]){
            return 55;
        }
        else{
            return 0;
        }   
    }
    return [EventParticipantCell getHeight];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        static NSString *cellIdentifier = @"EventParticipantInviteCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            cell.editingAccessoryView = [UIImageView imageNamed:@"arrow-white-right"];
            cell.accessoryView = [UIImageView imageNamed:@"arrow-white-right"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.backgroundColor = [UIColor customBackgroundHeader];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont customContentRegular:14];
        }
        
        cell.textLabel.text = NSLocalizedString(@"EVENT_PARTICIPANT_INVITE", nil);
        
        return cell;
    }
    else{
        static NSString *cellIdentifier = @"EventParticipantCell";
        EventParticipantCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(!cell){
            cell = [[EventParticipantCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        FLUser *user = [[_event participants] objectAtIndex:indexPath.row];
        [cell setUser:user];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section != 0){
        return;
    }
    
    FriendPickerViewController *controller = [FriendPickerViewController new];
    controller.dictionary = [NSMutableDictionary new];
    [controller setEvent:_event];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
