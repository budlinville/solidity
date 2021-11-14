//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;
// -----------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// -----------------------------------------

interface ERC20Interface {
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
	string public name = 'Cryptos';
	string public symbol = 'CRPT';
	uint public decimals = 0;

	uint public override totalSupply;

	address public founder;
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

	// added virtual so we can override in CryptosICO
	function transfer(address to, uint tokens) public virtual override returns(bool success) {
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

	// added virtual so we can override in CryptosICO
	function transferFrom(address from, address to, uint tokens) public virtual override returns(bool success) {
		require(allowed[from][to] >= tokens);
		require(balances[from] >= tokens);
		balances[from] -= tokens;
		balances[to] += tokens;
		allowed[from][to] -= tokens;

		return true;
	}
}

contract CryptosICO is Cryptos {
	// uint ONE_HOUR = 3600;  // 3600 seconds in one hour
	uint ONE_WEEK = 604800;

	address public admin;
	address payable public deposit;

	uint tokenPrice = 0.001 ether;  // 1 ETH = 1000 CRPT, 1 CRPT = 0.001 ETH
	uint public hardCap = 300 ether;
	uint public raisedAmount;
	uint public saleStart = block.timestamp; // starts immediately
	// uint public saleStart = block.timestamp + ONE HOUR;
	uint public saleEnd = block.timestamp + ONE_WEEK;
	uint tokenTradeStart = saleEnd + ONE_WEEK;  // transferable a week after ICO
	uint minInvestment = 0.1 ether;
	uint maxInvestment = 5 ether;

	enum State { beforeStart, running, afterEnd, halted }
	State public icoState;

	constructor(address payable _deposit) {
		deposit = _deposit;
		admin = msg.sender;
		icoState = State.beforeStart;
	}

	modifier onlyAdmin() {
		require(msg.sender == admin);
		_;
	}

	function halt() public onlyAdmin {
		require(icoState == State.running);
		icoState = State.halted;
	}

	function resume() public onlyAdmin {
		require(icoState == State.halted);
		icoState = State.running;
	}

	function changeDepositAddress(address payable newDeposit) public onlyAdmin {
		deposit = newDeposit;
	}

	function getCurrentState() public view returns(State) {
		if (icoState == State.halted) {
			return State.halted;
		} else if (block.timestamp < saleStart) {
			return State.beforeStart;
		} else if (block.timestamp >= saleStart && block.timestamp <= saleEnd) {
			return State.running;
		} else {
			return State.afterEnd;
		}
	}

	event Invest(address investor, uint value, uint tokens);

	function invest() payable public returns(bool) {
		icoState = getCurrentState();
		require(icoState == State.running);

		require(msg.value >= minInvestment && msg.value <= maxInvestment);
		raisedAmount += msg.value;
		require(raisedAmount <= hardCap);

		uint tokens = msg.value / tokenPrice;
		balances[msg.sender] += tokens;
		balances[founder] -= tokens;
		deposit.transfer(msg.value);
		emit Invest(msg.sender, msg.value, tokens);

		return true;
	}

	receive() payable external {
		invest();
	}

	// Override below two functions to "lock" tokens until after tokenTradeStart

	function transfer(address to, uint tokens) public override returns(bool success) {
		require(block.timestamp > tokenTradeStart);
		Cryptos.transfer(to, tokens);  // or super.transfer(to, tokens);
		return true;
	}

	function transferFrom(address from, address to, uint tokens) public override returns(bool success) {
		require(block.timestamp > tokenTradeStart);
		Cryptos.transferFrom(from, to, tokens);
		return true;
	}

	// What to do with tokens not minted during ICO (if there are any)?
	// They are in possession of the owner
	// Could "burn" them, Could transfer to account we don't have private key to
	// ... Orrrr we could keep them >:)
	// ... But burning them will generally help increase price of token and is considered best practice

	function burn() public returns(bool) {
		icoState= getCurrentState();
		require(icoState == State.afterEnd);
		balances[founder] = 0;
		return true;
	}
}