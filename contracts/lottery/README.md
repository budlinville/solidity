# Lottery
## Algorithm
* Lottery starts by accepting eth transactions. Anyone with a wallet can send a fixed amount of 0.1 eth directly to the contract's address, thus registering the player's wallet address.
* A user can send as many transactions as they want, thus increasing their chances of winning.
* There is a manager, an account that deploys and controls the contract.
* If there are at least three players, he can pick a random winner from the players list. Only the manager is allowed to see the contract balance to randomly select the winner.
* The contract will trasfer the entire balance to the winners address and the lottery is reset and ready for the next round.