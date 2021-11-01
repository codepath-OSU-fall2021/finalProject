# Eighth Wonder Finance

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
An application where users can simulate trading stocks with a starting balance of fake money. There will be a screen to research stock prices as well as a screen to show the user's current balance with profit and loss of stocks that they bought. Additionally, there will be a tab to show the user's profile.

### App Evaluation
- **Category:** Finance / Gaming
- **Mobile:** This app will be developed primarily for mobile devices. Future consideration may be given to a desktop version.
- **Story:** Stock trading game where users can simulate trading stocks with a starting balance of fake money. Users can research stock prices, see the current balance of their holdings, and view their user profile.
- **Market:** Any individual interested in stock trading could download this app and play the game. 
- **Habit:** The app could be used as often as the user wants depending on their appetite for trading stocks and checking in on their balance (i.e. gains and losses). 
- **Scope:** Our first objective is to allow users to research stock prices using the ticker symbol for a publicly traded company. This could evolve into a stock trading game with users competing in seasonal tournaments for prizes, similar to fantasy football apps. Large potential for use with brokerage accounts, electronic trading platforms, or social media platforms such as Facebook.  

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**


* User can see current price of stocks as well as a logo of the company
* User can research stock information by ticker symbol
* User can purchase and sell shares of stock using a hypothetical balance of cash
* User can view the current balance of their portfolio


**Optional Nice-to-have Stories**

* Being able to log in using Facebook
* Using faceID to unlock the application
* Ability to search for stock information using auto-complete based on ticker symbol, name, or sector

### 2. Screen Archetypes

* Stock Information
   * User can see current price of stocks as well as a logo of the company
   * User can select a company to view more information as well as purchase shares
* Research Page
   * User can research stock information by ticker symbol
* User Profile
   * User can view the current balance of their portfolio
   * User can sell shares of a stock they own

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home tab
* Research tab
* Profile tab

Optional:
* Setting tab

**Flow Navigation** (Screen to Screen)

* Login -> Main screen
* Stock Information - > Stock information and and Purchase button
* Profile -> User can sell shares of a stock they own

Optional:
* Forced Log-in -> Account creation if no login is available
* Setting - > Log-out

## Wireframes
<img src="drawn_wireframe.jpeg" width=600>

### [BONUS] Digital Wireframes & Mockups

<img src="https://user-images.githubusercontent.com/81477294/139751047-1ab9de59-8600-49e9-ba55-dddfc30718b3.png" width=600>

### [BONUS] Interactive Prototype

## Schema 

### Models
#### User

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for the User (default field) |
   | username      | String   | username |
   | password      | String   | password |
   | balance       | Number   | balance of cash in users account |
   | holdings      | Array of StockSnapshots | stocks currently held by user |
   | trades        | Array of Trades | array of trades made by user |
   | profileImage  | File     | image that user uploads |

#### StockSnapshot

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for the StockSnapshot (default field) |
   | user          | Pointer to User | user that holds this stock |
   | symbol        | String   | stock symbol |
   | price         | Number   | stock price at time of creation |
   | quantity      | Number   | stock quantity held by user |
   | createdAt     | DateTime | time StockSnapshot was created (default field) |

#### Trade

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for the Trade (default field) |
   | user          | Pointer to User | user that made the trade |
   | stock         | Pointer to StockSnapshot | stock snapshot |
   | tradeType     | String | Buy or Sell |
   | quantity      | Number   | Number of stocks bought or sold  |
   | sellPrice     | Number   | Price of the stock when sold  |
   | createdAt     | DateTime | time Trade was created (default field) |

### Networking
- Home Feed Screen
   - (Read/GET) Query all StockSnapshots where user is currentUser
      ```swift
      let query = PFQuery(className:"StockSnapshot")
      query.whereKey("user", equalTo: currentUser)
      query.order(byDescending: "symbol")
      query.findObjectsInBackground { (stocks: [PFObject]?, error: Error?) in
         if let error = error { 
            print(error.localizedDescription)
         } else if let stocks = stocks {
            print("Successfully retrieved \(stocks.count) stock snapshots for \(currentUser).")
         // TODO: Calculate each symbols stock quantity and total cost to purchase
         }
      }
      ```
   - (Read/GET) Query API for each symbol's current price and calculate users current value held
- Sell Screen
   - (Create/POST) Create a trade (or trades) of stock snapshots
   - (Read/GET) Get stock logo from API
   - (Update/PUT) Update StockSnapshot quantities
   - (Update/PUT) Remove from User.holdings is StockSnapshot.quantity is zero
- Buy Screen
   - (Create/POST) Create a StockSnapshot
   - (Read/GET) Get stock logo from API
   - (Create/POST) Create a Trade
   - (Update/PUT) Add StockSnapshot and Trade to user
- Research
   - (Read/GET) Top stocks from API
   - (Read/GET) Get logos for top stocks in API
   - (Read/GET) Stock searched for in API (to see if it exists)
- Research Detail
   - (Read/GET) Stock information from API
- Profile Screen
   - (Read/GET) Query user information
      ```swift
      let query = PFQuery(className:"User")
      query.whereKey("objectId", equalTo: currentUser)
      query.includeKeys(["trades", "trades.stock"])
      query.order(byDescending: "createdAt")
      query.findObjectsInBackground { (stocks: [PFObject]?, error: Error?) in
         if let error = error { 
            print(error.localizedDescription)
         } else if let trades = trades {
            print("Successfully retrieved \(trades.count) stock snapshots for \(currentUser).")
         // TODO: Display trades made by user
         }
      }
      ```


##### IEX Cloud API 
- Base URL - [https://cloud.iexapis.com/stable](https://cloud.iexapis.com/stable)

   HTTP Verb | Endpoint | Description | Credits
   ----------|----------|------------|------------
    `GET`    | /stock/{symbol}/quote | current price, name and stock info | 1
    `GET`    | /stock/{symbol}/company | company description paragraph and info | 10
    `GET`    | /stock/market/list/{list-type} | list of 10 quotes based on list-type (mostactive, gainers, losers) | ~10
    `GET`    | /stock/{symbol}/logo | logo for symbol | 1

