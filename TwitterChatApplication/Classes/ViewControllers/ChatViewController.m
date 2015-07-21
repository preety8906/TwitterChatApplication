//
//  ChatViewController.m
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

#import "ChatViewController.h"
#import "ChatTableCell.h"
#import "Constants.h"

@interface ChatViewController ()

@property (strong, nonatomic) IBOutlet UITableView *messagesTable;
@property (strong, nonatomic) IBOutlet UITextField *messageTextBox;
@property (strong, nonatomic) IBOutlet UIView      *bottomContainerView;
@property (strong, nonatomic) IBOutlet UIButton *postButton;

@property (strong, nonatomic) NSMutableArray *messagesList;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation ChatViewController

@synthesize title;
@synthesize messagesTable;
@synthesize messageTextBox;
@synthesize bottomContainerView;
@synthesize postButton;
@synthesize messagesList;
@synthesize timer;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = title;
    
    // dummy messages
    self.messagesList = [[NSMutableArray alloc] initWithObjects: @"Hello!", @"Hello! Hello!", @"The quick brown fox jumps over the crazy dog and it is so funny.", @"The quick brown fox jumps over the crazy dog and it is so funny. The quick brown fox jumps over the crazy dog and it is so funny.", nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    // add notification observers
    [self addObservers];
}

-(void) viewDidDisappear:(BOOL)animated
{
    // remove notification observers
    [self removeObservers];
}

#pragma mark - Other methods

-(void) addObservers
{
    // Keyboard notifications added.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void) receivedReply
{
    // reply should be twice as the sent message: Requirement
    NSString *replyMsg = [self.messagesList objectAtIndex: self.messagesList.count - 1];
    [self.messagesList addObject: [NSString stringWithFormat: @"%@ %@", replyMsg, replyMsg]];
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow: self.messagesList.count - 1
                                                inSection: 0];
    
    // insert row for reply
    [self.messagesTable beginUpdates];
    [self.messagesTable insertRowsAtIndexPaths: [NSArray arrayWithObject: indexpath] withRowAnimation: UITableViewRowAnimationBottom];
    [self.messagesTable endUpdates];
    
    [self.messagesTable scrollToRowAtIndexPath: indexpath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect tableFrame = self.messagesTable.frame;
    tableFrame.size.height -= kbSize.height;
    self.messagesTable.frame = tableFrame;
    
    // adjust frames when keyboard comes up
    CGRect bottomViewFrame = self.bottomContainerView.frame;
    bottomViewFrame.origin.y -= kbSize.height;
    self.bottomContainerView.frame = bottomViewFrame;
    
    [self.messagesTable scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: self.messagesList.count - 1 inSection: 0]
                              atScrollPosition: UITableViewScrollPositionBottom
                                      animated: YES];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    // reset frames to default when keyboard hides
    CGRect tableFrame = self.messagesTable.frame;
    tableFrame.size.height = self.view.frame.size.height - self.bottomContainerView.frame.size.height;
    self.messagesTable.frame = tableFrame;
    
    CGRect bottomViewFrame = self.bottomContainerView.frame;
    bottomViewFrame.origin.y = self.view.frame.size.height - bottomViewFrame.size.height;
    self.bottomContainerView.frame = bottomViewFrame;
}

#pragma mark - UITableView Datasource

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return messagesList.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = CELL_ID_MY_CHAT;
    int mod = fmodf(indexPath.row, 2.0f);
    BOOL isMychat = YES;
    
    // for now, all even ranked cells are my chats and odd ranked are of follower's since real time chat is notimplemented here.
    if (mod == 1)
    {
        identifier = CELL_ID_FRIEND_CHAT;
        isMychat = NO;
    }

    ChatTableCell *cell = (ChatTableCell *)[tableView dequeueReusableCellWithIdentifier: identifier];
    
    if (cell == nil)
    {
        cell = (ChatTableCell *)[[[NSBundle mainBundle] loadNibNamed: NIB_CHAT_TABLE_CELL owner:self options: nil] objectAtIndex: mod];
    }
    cell.isMyChat = isMychat;
    cell.message = [self.messagesList objectAtIndex: indexPath.row];
    
    return cell;
}

#pragma mark - UITableView Delegate

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight  = CHAT_CELL_MIN_HEIGHT;
    float  cellWidth    = tableView.frame.size.width * 3/4;
    NSString *message   = [messagesList objectAtIndex: indexPath.row];
    
    // calculate height of table cell from the message
    CGRect expectedRect = [message boundingRectWithSize: CGSizeMake(cellWidth, UILABEL_MAX_HEIGHT)
                                                options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                             attributes: @{NSFontAttributeName: [UIFont fontWithName: FONT_NAME size: FONT_SIZE]}
                                                context: nil];
    if (expectedRect.size.height > CHAT_TEXT_MIN_HEIGHT)
    {
        cellHeight = expectedRect.size.height + 4 * CHAT_CELL_BUFFERS; //total 20.0f = total space that should be left
    }
    
    return cellHeight;
}

#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    postButton.enabled = YES;
    
    // disable post button if the text field is empty. need to if=gnore only white spaces also. Not implemented here but should be in future.
    if (string.length == 0)
        postButton.enabled = NO;
    
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.messageTextBox resignFirstResponder];
    return YES;
}

#pragma mark - UIButton action

-(IBAction) postMessgae:(id)sender
{
    [self.messagesList addObject: self.messageTextBox.text];
    self.messageTextBox.text = @"";
    
    // Add new cell in the chat table
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow: self.messagesList.count - 1
                                                inSection: 0];
    
    [self.messagesTable beginUpdates];
    [self.messagesTable insertRowsAtIndexPaths: [NSArray arrayWithObject: indexpath] withRowAnimation: UITableViewRowAnimationBottom];
    [self.messagesTable endUpdates];
    [self.messagesTable scrollToRowAtIndexPath: indexpath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
    
    // start timer to get reply after 1 second.
    [self performSelector: @selector(receivedReply) withObject: nil afterDelay: 1.0];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
