//
//  EditReminderViewController.m
//  EventSync
//
//  Created by mtaniuchi on 13/07/28.

/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Masahiro Taniuchi, Tiesfeed Software JP.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "EditReminderViewController.h"

#import <EventKit/EventKit.h>
#import "RemListViewController.h"
#import "EventUtil.h"


@interface EditReminderViewController ()

@end

@implementation EditReminderViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"Title", nil);
        case 1:
            return NSLocalizedString(@"Date", nil);
        case 2:
            return NSLocalizedString(@"Place", nil);
        case 3:
            return NSLocalizedString(@"Priority", nil);
        case 4:
            return NSLocalizedString(@"List", nil);
        case 5:
            return NSLocalizedString(@"Memo", nil);
        default:
            return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: //Title
            return 1;
        case 1: //Date
            return 4;
        case 2: //Place
            return 4;
        case 3: //Priority
            return 1;
        case 4: // List
            return 1;
        case 5: // Memo
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReminderCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleValue1
                             reuseIdentifier:CellIdentifier];
    
    switch (indexPath.section) {
        case 0: //Title
            cell.textLabel.text = self.editingReminder.title;
            break;
        case 1: //Date
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Alarms";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
                                             self.editingReminder.hasAlarms ? @"ON" : @"OFF"];
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"DueDate", nil);
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
                                       [self.editingReminder.dueDateComponents date]];
            } else if (indexPath.row == 2) {
                cell.textLabel.text = NSLocalizedString(@"Frequency", nil);
                if (self.editingReminder.recurrenceRules != nil &&
                    self.editingReminder.recurrenceRules.count > 0)
                {
                    EKRecurrenceRule *rule = [self.editingReminder.recurrenceRules objectAtIndex:0];
                    cell.detailTextLabel.text = [EVTUTIL valueToString:rule.frequency];
                }
            } else if (indexPath.row == 3) {
                cell.textLabel.text = NSLocalizedString(@"EndOfRecurrence", nil);
                if (self.editingReminder.recurrenceRules != nil &&
                    self.editingReminder.recurrenceRules.count > 0)
                {
                    EKRecurrenceRule *rule = [self.editingReminder.recurrenceRules objectAtIndex:0];
                    EKRecurrenceEnd *end = rule.recurrenceEnd;
                    
                    if (end == nil) {
                        
                    } else {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", end.endDate];
                    }
                } else {
                    cell.detailTextLabel.text = NSLocalizedString(@"None", nil);
                }
            }
            break;
        case 2: //Place
            break;
        case 3: //Priority
            cell.textLabel.text = [NSString stringWithFormat:@"%d", self.editingReminder.priority];
            break;
        case 4: //List
            break;
        case 5: //Memo
            cell.textLabel.text = self.editingReminder.notes;
            break;
        default:
            break;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
