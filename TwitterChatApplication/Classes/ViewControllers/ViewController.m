//
//  ViewController.m
//  TwitterChatApplication
//
//  Created by Preety Pednekar on 7/12/15.
//  Copyright (c) 2015 Preety Pednekar. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "ViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "ChatViewController.h"
#import "Constants.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITableView *followersListTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) NSMutableArray *followersListData;

@end

@implementation ViewController

@synthesize followersListTable;
@synthesize spinner;
@synthesize followersListData;

-(void) populateDummyDataWithAlertMessge: (NSString *) message
{
    // show message about why the dummy data is populated
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message: message delegate: nil cancelButtonTitle: BTN_TITLE_OK otherButtonTitles: nil];
    [alert show];
    
    // prepare dummy data
    NSArray *dummyNames = [[NSArray alloc] initWithObjects: @"twitter_id", @"aaaaa", @"bbbbb", @"ccccc", @"ddddd", @"eeeee", @"ggggg", @"hhhhh", @"iiiii", @"jjjjj", @"kkkkk", @"lllll", @"mmmmm", @"nnnnn", nil];
    
    self.followersListData = [[NSMutableArray alloc] init];
    
    // prepare as per the actual data. Need to be array of dictionaries
    for (NSString *name in dummyNames)
    {
        NSDictionary *followerDict = [NSDictionary dictionaryWithObject: name forKey: KEY_SCREEN_NAME];
        [self.followersListData addObject: followerDict];
    }
    
    // hide spinner and reload the table
    self.followersListTable.hidden = NO;
    [self.followersListTable reloadData];
    [self.spinner stopAnimating];
}

-(void) getTwitterFollowers
{
    // Get access to all Twitter accounts
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType  *accountType  = [accountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType: accountType
                                          options: nil
                                       completion: ^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             // get all accounts if accessed
             NSArray *allAccounts = [accountStore accountsWithAccountType: accountType];
             
             if (allAccounts.count > 0)
             {
                 ACAccount *twitterAccount = [allAccounts objectAtIndex: 0];
                 NSURL *twitterURL = [NSURL URLWithString: URL_TWITTER_FOLLOWERS];
                 NSDictionary *parameters = [NSDictionary dictionaryWithObject: twitterAccount.username forKey: KEY_SCREEN_NAME];
                 
                 // get user info.
                 SLRequest *twitterInfoRequest = [SLRequest requestForServiceType: SLServiceTypeTwitter
                                                                    requestMethod: SLRequestMethodGET
                                                                              URL: twitterURL
                                                                       parameters: parameters];
                 [twitterInfoRequest setAccount: twitterAccount];
                 
                 // send request
                 [twitterInfoRequest performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          
                          if ([urlResponse statusCode] == 429)
                          {
                              NSLog(@"Rate limit is reached.");
                              return;
                          }
                          
                          if (error)
                          {
                              NSLog(@"Error: %@", error.localizedDescription);
                              return;
                          }
                          
                          // check the response data
                          if (responseData)
                          {
                              NSError *error = nil;
                              NSDictionary *twDataDict = [NSJSONSerialization JSONObjectWithData: responseData options: NSJSONReadingMutableLeaves error: &error];
                              
                              if (!error)
                              {
                                  self.followersListData = [twDataDict objectForKey: KEY_USERS];
                                  if (self.followersListData.count)
                                  {
                                      // if followers list is received, reload table with it
                                      self.followersListTable.hidden = NO;
                                      [self.followersListTable reloadData];
                                      [self.spinner stopAnimating];
                                  }
                                  else
                                  {
                                      // no followers are available. So populate the table with dummy data and the alert message at the beginning
                                      [self populateDummyDataWithAlertMessge: ERR_NO_FOLLOWERS_AVAILABLE];
                                  }
                              }
                              else
                              {
                                  NSLog(@"Error: %@", error.localizedDescription);
                              }
                          }
                      });
                  }];
             }
         }
     }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = SCREEN_TITLE_FOLLOWERS_LIST;
    self.followersListTable.hidden = YES;
    [self.spinner startAnimating];
    
    if ([SLComposeViewController isAvailableForServiceType: SLServiceTypeTwitter])
    {
        // Twitter account is avilable.
        [self getTwitterFollowers];
    }
    else
    {
        // Twitter account is unavilable. so populate the dummy data
        [self populateDummyDataWithAlertMessge: ERR_NO_TWEET_ACCNT_AVAILABLE];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.followersListData.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = CELL_ID_FOLLOWER_LIST;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: identifier];
    }
    
    // create cell
    NSDictionary *followerInfo = [self.followersListData objectAtIndex: indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"@%@", [followerInfo valueForKey: KEY_SCREEN_NAME]];
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // on follower selection, push chat view controller
    [self performSegueWithIdentifier: SEGUE_PUSH_CHAT_VC sender: [self.followersListData objectAtIndex: indexPath.row]];
}

#pragma mark - Segue actions

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: SEGUE_PUSH_CHAT_VC])
    {
        // push chat view controller
        NSDictionary *follower = (NSDictionary *) sender;
        ChatViewController *chatVC = (ChatViewController *)segue.destinationViewController;
        chatVC.title = [NSString stringWithFormat: @"@%@", [follower valueForKey: KEY_SCREEN_NAME]];
    }
}

#pragma mark - Memory warnings

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
