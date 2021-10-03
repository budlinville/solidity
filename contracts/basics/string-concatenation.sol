//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract StringConcat {
    // No built in way to concatenate strings. Can use abi's encodePacked, but will return bytes instead
    function concat(string memory s1, string memory s2) public pure returns(bytes memory) {
        return abi.encodePacked(s1, s2);
    }
}