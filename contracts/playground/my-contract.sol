// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.0;

contract Property {
    int public value;
    
    function setValue(int _value) public {
        value = _value;
    }
}

// 0xf8e81D47203A594245E36C48e151709F0C19fBe8