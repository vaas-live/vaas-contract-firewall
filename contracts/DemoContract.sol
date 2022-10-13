// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {VaasAddressScreening} from "./vaas/VaasAddressScreening.sol";

// This is a demo contract that validate the address who is interacting with
// using the Vaas compliance API.
contract DemoContract is VaasAddressScreening {

    // The method receive from the Vaas API call the timestamp of when the API did the screening, and also the
    // vaas api signature containing the address that is clear to interact with
    function exampleMethod(uint256 _vaasTimestamp, bytes memory _vaasHashSignature) public view{
        // the super classe method will do the validation of the address
        require(super.validateAddress(msg.sender, _vaasTimestamp, _vaasHashSignature), 'vaas invalid address signature');

        // if this point is reached, the msg.sender address is clear to interact with the contract
        // TODO implement contrat rules
    }

}