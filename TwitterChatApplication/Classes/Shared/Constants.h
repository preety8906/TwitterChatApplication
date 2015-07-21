//
//  Constants.h
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

#ifndef TwitterChatApplication_Constants_h
#define TwitterChatApplication_Constants_h

// Urls
#define URL_TWITTER_FOLLOWERS               @"https://api.twitter.com/1.1/followers/list.json"

// Dictionary keys
#define KEY_SCREEN_NAME                     @"screen_name"
#define KEY_USERS                           @"users"

// Screen titles
#define SCREEN_TITLE_FOLLOWERS_LIST         @"Twitter DM"

// Nib name
#define NIB_CHAT_TABLE_CELL                 @"ChatTableCell"

// Error message
#define ERR_NO_FOLLOWERS_AVAILABLE          @"No followers available. So populated with dummy data."
#define ERR_NO_TWEET_ACCNT_AVAILABLE        @"Twitter account is unavailable, so populated with dummy data. Please check twitter account and relaunch the application."

// constants
#define UILABEL_MAX_HEIGHT                  9999
#define CHAT_CELL_MIN_HEIGHT                58.0f
#define CHAT_TEXT_MIN_HEIGHT                18.0f
#define CHAT_CELL_BUFFERS                   10.0f

#define FONT_NAME                           @"Arial"
#define FONT_SIZE                           14.0f

#define SEGUE_PUSH_CHAT_VC                  @"pushChatVCSegue"

// StoryBoard identifiers
#define ID_CHAT_VC                          @"idChatVC"

// cells reuse identifier
#define CELL_ID_FOLLOWER_LIST               @"followersListCell"
#define CELL_ID_FRIEND_CHAT                 @"followerChatCell"
#define CELL_ID_MY_CHAT                     @"myChatCell"

// button titles
#define BTN_TITLE_OK                        @"Ok"

#endif
