// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 < 0.9.0;

contract AuctionCreator {
	Auction[] public auctions;

	function createAuction() public {
		Auction newAuction = new Auction(msg.sender);
		auctions.push(newAuction);

	}
}

contract Auction {
	address payable public owner;
	uint public startBlock;
	uint public endBlock;
	string public ipfsHash;
	
	enum State { Started, Running, Ended, Cancelled }
	State public auctionState;

	uint public highestBindingBid;
	address payable public highestBidder;

	mapping(address => uint) public bids;
	uint bidIncrement;

	constructor(address eoa) {
		// uint ONE_WEEK = 40320;  // new block every 15 seconds => 40320 blocks in 1 WEEK
		owner = payable(eoa);
		auctionState = State.Running;
		startBlock = block.number;
		// endBlock = startBlock + ONE_WEEK;
        endBlock = startBlock + 3;
		ipfsHash = "";
		bidIncrement = 1000000000000000000;
	}

	modifier notOwner() {
		require(msg.sender != owner);
		_;
	}

	modifier afterStart() {
		require(block.number >= startBlock);
		_;
	}

	modifier beforeEnd() {
		require(block.number <= endBlock);
		_;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	function min(uint a, uint b) pure internal returns(uint) {
		return a < b ? a : b;
	}

	function cancelAuction() public onlyOwner {
		auctionState = State.Cancelled;
	}

	function placeBid() public payable notOwner afterStart beforeEnd {
		require(auctionState == State.Running);
		require(msg.value >= 100);

		// current bid = money already committed plus money just sent
		uint currentBid = bids[msg.sender] + msg.value;
		require(currentBid > highestBindingBid);

		bids[msg.sender] = currentBid;

		if (currentBid <= bids[highestBidder]) {
			highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]);
		} else {
			highestBindingBid = min(currentBid, bids[highestBidder] + bidIncrement);
			highestBidder = payable(msg.sender);
		}
	}
	
	function finalizeAuction() public {
	    require(auctionState == State.Cancelled || block.number > endBlock);
	    require(msg.sender == owner || bids[msg.sender] > 0);
	    
	    address payable recipient;
	    uint value;
	    
	    if (auctionState == State.Cancelled) {  // auction cancelled
	        recipient = payable(msg.sender);
	        value = bids[msg.sender];
	    } else {
	        if (msg.sender == owner) {  // this is owner
	            recipient = owner;
	            value = highestBindingBid;
	        } else {  // this is a bidder
	            if (msg.sender == highestBidder) {
	                recipient = highestBidder;
	                value = bids[highestBidder] - highestBindingBid;
	            } else {  // this is neither the owner nor the highestBidder
	                recipient = payable(msg.sender);
	                value = bids[msg.sender];
	            }
	        }
	    }
	    // Reset bid to 0, so user can't request his money back multiple times
	    bids[recipient] = 0;
	    recipient.transfer(value);
	}
}