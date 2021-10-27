// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

// This doesn't seem to work with solidity 0.8

contract Lottery {
	address payable[] public players;  // two types of addresses - payable and nonpayable
	address payable public manager;

	constructor() {
		manager = payable(msg.sender);
		players.push(payable(msg.sender));  // challenge 2
	}

	receive() external payable {
		require(msg.value == 1 ether);
		require(msg.sender != manager);  // challenge 1
		players.push(payable(msg.sender));  // convert sender's address to payable address
	}

	function getBalance() public view returns(uint) {
		require(msg.sender == manager);
		return address(this).balance;
	}

	function random() internal view returns(uint) {
		// generally not a good idea to use this to generate a random number
		// In solidity, must use an off-blockchain resource to get a random number
		return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
	}

	function pickWinner() public {
	    if (players.length < 10) {  // challenge 3
		    require(msg.sender == manager);
	    }
		require(players.length >= 3);

		uint r = random();
		address payable winner;

		uint index = r % players.length;
		winner = players[index];
		
		uint winnersCut = getBalance() * 9 / 10;  // challenge 4
		uint managersCut = getBalance() - winnersCut;
		// transfer is member function of any payable address
		winner.transfer(winnersCut);
		manager.transfer(managersCut); 
	}
}