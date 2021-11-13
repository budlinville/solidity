//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract BaseContract {
	int public x;
	address public owner;

	constructor() {
		x = 5;
		owner = msg.sender;
	}

	function setX(int _x) public {
		x = _x;
	}
}

// Note that when deploying derived contract, base contract DOES NOT also get deployed
contract A is BaseContract {
	int public y = 3;
}

abstract contract AbstractBaseContract {
	int public x;
	address public owner;

	constructor() {
		x = 5;
		owner = msg.sender;
	}

	function setX(int _x) public virtual;
}

// Can either mark this contract as abstract OR implement setX()
// i.e. Contracts that derive from abstract contracts must implement all virtual methods
// OR be marked abstract themselves
contract B is AbstractBaseContract {
	function setX(int _x) public override { }	
}

interface InterfaceBaseContract {
	// no state variables or constructor

	function setX(int _x) external;
}

contract C is InterfaceBaseContract {
	int public x;
	int public y = 3;

	function setX(int _x) public override {
		x = _x;
	}
}