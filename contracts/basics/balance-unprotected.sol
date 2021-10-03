//SPDX-License-Identifier: GPL-3.0
 
 
pragma solidity >=0.6.0 <0.9.0;


contract Deposit {
    receive() external payable {}
    
    fallback() external payable {}
    
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    // Transfers THIS contract's eth balance to a specified account
    // Note that ANYONE can access this contract's balance => Not very secure, yeah?
    function transferEther(address payable recipient, uint amount) public returns(bool) {
        if (amount <= getBalance()) {
            recipient.transfer(amount);
            return true;
        } else {
            return false;
        }
    }
}