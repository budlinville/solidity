pragma solidity >=0.7.0 <0.9.0;

contract howCoin {
    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;

    // Constants Probably accessed outside this class
    string public name = "howCoin";
    string public symbol = "HOW";
    uint256 public max_supply = 42000000000000;  // 42 million + 6 decimals
    uint256 public unspent_supply = 0;
    uint256 public spendable_supply = 0;
    uint256 public circulating_supply = 0;
    uint256 public decimals = 6;
    uint256 public reward = 50000000;  // 50 + 6 decimals
    uint256 public timeOfLastHalving = block.timestamp;  // block.timestamp = now (now deprecated)
    uint public timeOfLastIncrease = block.timestamp;
    
    uint FOUR_YEARS = 2100000 minutes;  // ~4 years
    uint INCREASE_DELTA = 150 seconds;  // Use 1 second for development
    uint WEI_EXCHANGE_RT = 100000000;   // 1 WEI = 100000000 howCoin... does this rate change ever?

    // events people can listen to.. not necessary, but gives added completeness
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed from, uint256 value);

    // Initializes contract with initial supply tokens to the creator of the contract
    constructor() {
        timeOfLastHalving = block.timestamp;
    }

    /*  Updates supply by {reward} every {INCREASE_DELTA}
     *  Halves supply every {FOUR_YEARS}
     *  Note : Called from transfer() function because our contract is only executed whenever someone trasfers coins
     *      => in practice, won't update supply every 150 seconds if coin is used infrequently
     *  Return : returns amount of coins in circulation
     */
    function updateSupply() internal returns (uint256) {
        // Halve supply every four years
        if (block.timestamp - timeOfLastHalving >= FOUR_YEARS) {
            reward /= 2;
            timeOfLastHalving = block.timestamp;
        }

        // Slightly increase supply
        if (block.timestamp - timeOfLastIncrease >= INCREASE_DELTA) {
            uint256 increaseAmount = ((block.timestamp - timeOfLastIncrease) / 150 seconds) * reward;
            spendable_supply += increaseAmount;
            unspent_supply += increaseAmount;
            timeOfLastIncrease = block.timestamp;
        }

        circulating_supply = spendable_supply - unspent_supply;

        return circulating_supply;
    }

    // Send coins
    function transfer(address _to, uint256 _value) public payable {
        require(balanceOf[msg.sender] >= _value);           // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflows
        balanceOf[msg.sender] -= _value;                    // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient

        updateSupply();

        // Notify anyone listening that the transfer took place
        Transfer(msg.sender, _to, _value);
    }
    
    // Run when someone buys our coin with ether
    function mint() public payable {
        uint256 _value = msg.value / WEI_EXCHANGE_RT;
        require(balanceOf[msg.sender] + _value >= balanceOf[msg.sender]); // Check for overflows

        updateSupply();

        require(unspent_supply - _value <= unspent_supply);
        unspent_supply -= _value; // Remove from unspent supply
        balanceOf[msg.sender] += _value; // Add the same to the recipient

        updateSupply();

        // Notify anyone listening that the minting took place
        Mint(msg.sender, _value);
    }

    function withdraw(uint256 amountToWithdraw) public returns (bool) {

        // Balance given in HOW

        require(balanceOf[msg.sender] >= amountToWithdraw);
        require(balanceOf[msg.sender] - amountToWithdraw <= balanceOf[msg.sender]);

        // Balance checked in HOW, then converted into Wei
        balanceOf[msg.sender] -= amountToWithdraw;

        // Added back to supply in HOW
        unspent_supply += amountToWithdraw;
        // Converted into Wei
        amountToWithdraw *= WEI_EXCHANGE_RT;

        // Transfered in Wei
        msg.sender.transfer(amountToWithdraw);

        updateSupply();

        return true;
    }
}