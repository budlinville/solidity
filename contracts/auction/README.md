# Auction

## Description
* decentralized auction - Ebay alternative

## Algorithm
* auction has owner, start date, and end date
* owner can cancel auction or finalize auction after end time
* people send Eth by calling function placeBid()
* users bid up to their maximum, but are bound to the previous bid plus an increment
	* highestBindingBid = selling price
	* highestBidder = person who won the auction
* owner gets highest binding bid and everyone else withdraws their own amount