//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;
// -----------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// -----------------------------------------

// NOTE: Below is a full ERC20 token implementation, commented for your benefit.

interface ERC20Interface {
	// Below three required for transferring from one contract to another
	function totalSupply() external view returns(uint);
	function balanceOf(address tokenOwner) external view returns(uint balance);
	function transfer(address to, uint tokens) external returns(bool success);

	function allowance(address tokenOwner, address spender) external view returns(uint remaining);
	function approve(address spender, uint tokens) external returns(bool success);
	function transferFrom(address from, address to, uint tokens) external returns(bool success);

	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Cryptos is ERC20Interface {
	// Below three variables below are actually optional
	string public name = 'Cryptos';
	string public symbol = 'CRPT';
	uint public decimals = 0;  // Number of decimals after decimal point (18 is most commons)

	// Keyword 'public' automatically generates getter, so it is sufficient for this to be a state variable
	uint public override totalSupply;

	address public founder;  // also not required
	mapping(address => uint) public balances;
	mapping(address => mapping(address => uint)) allowed;

	constructor() {
		totalSupply = 1000000;
		founder = msg.sender;
		balances[founder] = totalSupply;
	}

	function balanceOf(address tokenOwner) public view override returns(uint balance) {
		return balances[tokenOwner];
	}

	function transfer(address to, uint tokens) public override returns(bool success) {
		require(balances[msg.sender] >= tokens);

		balances[to] += tokens;
		balances[msg.sender] -= tokens;
		emit Transfer(msg.sender, to, tokens);

		return true;
	}

	function allowance(address tokenOwner, address spender) view public override returns(uint) {
		return allowed[tokenOwner][spender];
	}

	function approve(address spender, uint tokens) public override returns(bool success) {
		require(tokens > 0);
		require(balances[msg.sender] >= tokens);

		allowed[msg.sender][spender] = tokens;

		emit Approval(msg.sender, spender, tokens);
		return true;
	}

	function transferFrom(address from, address to, uint tokens) public override returns(bool success) {
		require(allowed[from][to] >= tokens);
		require(balances[from] >= tokens);
		balances[from] -= tokens;
		balances[to] += tokens;
		allowed[from][to] -= tokens;

		return true;
	}
}