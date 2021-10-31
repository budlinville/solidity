// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract CrowdFunding {
	mapping(address => uint) public contributors;
	address public admin;
	uint public numContributors;
	uint public minContribution;
	uint public deadline;  // timestamp
	uint public goal;
	uint public raisedAmount;
	
	struct Request {
	    string description;
	    address payable recipient;
	    uint value;
	    bool completed;
	    uint numVoters;
	    mapping(address => bool) voters;
	}
	
	// Cannot have array of mappings in latest version of Solidity, so we use mapping of mappings instead
	mapping(uint => Request) public requests;
	uint public numRequests;  // need this because mapping does not automatically update indices like array does

	constructor(uint _goal, uint _deadline) {
		goal = _goal;
		deadline = block.timestamp + _deadline;  // cur time + deadline delta
		minContribution = 100 wei;
		admin = msg.sender;
	}
	
	event ContributeEvent(address _sender, uint _value);
	event CreateRequestEvent(string _description, address _recipient, uint _value);
	event MakePaymentEvent(address _recipient, uint _value);

	function contribute() public payable {
		require(block.timestamp < deadline, 'Deadline has passed!');
		require(msg.value >= minContribution, 'Minimum contributin not met!');

		if (contributors[msg.sender] == 0) {
			numContributors++;
		}

		contributors[msg.sender] += msg.value;
		raisedAmount += msg.value;
		
		emit ContributeEvent(msg.sender, msg.value);
	}

	receive() payable external {
		contribute();
	}

	function getBalance() public view returns(uint) {
		return address(this).balance;
	}

	function getRefund() public {
		require(contributors[msg.sender] > 0);
		require(block.timestamp > deadline && raisedAmount < goal);

		payable(msg.sender).transfer(contributors[msg.sender]);
		contributors[msg.sender] = 0;
	}
	
	modifier onlyAdmin() {
	    require(msg.sender == admin, 'Only admin can call this function!');
	    _;
	}
	
	function createRequest(string memory _description, address payable _recipient, uint _value) public onlyAdmin {
	    Request storage newRequest = requests[numRequests];
	    numRequests++;
	    
	    newRequest.description = _description;
	    newRequest.recipient = _recipient;
	    newRequest.value = _value;
	    newRequest.completed = false;
	    newRequest.numVoters = 0;
	    
	    emit CreateRequestEvent(_description, _recipient, _value);
	}
	
	function voteRequest(uint _requestNum) public {
	    require(contributors[msg.sender] > 0, 'You must be a contributor to vote!');
	    Request storage thisRequest = requests[_requestNum];
	    
	    require(thisRequest.voters[msg.sender] == false, 'You have already voted!');
	    thisRequest.voters[msg.sender] = true;
	    thisRequest.numVoters++;
	}
	
	function makePayment(uint _requestNum) public onlyAdmin {
	    require(raisedAmount >= goal);
	    Request storage thisRequest = requests[_requestNum];
	    require(thisRequest.completed == false, 'This request has been completed!');
	    require(thisRequest.numVoters > numContributors / 2);  // 50% voted for this request
	    
	    thisRequest.recipient.transfer(thisRequest.value);
	    thisRequest.completed = true;
	    
	    emit MakePaymentEvent(thisRequest.recipient, thisRequest.value);
	}
}