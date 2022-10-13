// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract VaasAddressScreening is Ownable {

    using ECDSA for bytes32;

    // the VAAS address who will sign the screening validation
    // of the users addresses
    address public vaasSignerAddress;

    // the amount of seconds that a screening will be valid (default is 15 minutes)
    uint256 public screeningTimeoutSeconds = 60 * 15;

    // panic button to stop validating the vaas signature
    bool public stopValidation = false;

    // sets the vaas address that will sign the message in our compliance API
    function setVaasSignerAddress(address _vaasSignerAddress)
        external
        virtual
        onlyOwner
    {
        vaasSignerAddress = _vaasSignerAddress;
    }

    // set the amount of time in seconds, that a screening address response, will
    // be valid. This field is used to validate the timestamp received in the api call.
    // validation applyed: require((_vaasTimestamp + screeningTimeoutSeconds) > block.timestamp);
    function setScreeningTimeoutSeconds(uint256 _screeningTimeoutSeconds)
        external
        virtual
        onlyOwner
    {
        screeningTimeoutSeconds = _screeningTimeoutSeconds;
    }

    // if by any reason the contract owner wants to disable the validation,
    // just et this var to true
    function setStopValidation(bool _stopValidation)
        external
        virtual
        onlyOwner
    {
        stopValidation = _stopValidation;
    }

    // validate if the _from address, has an approved screening in the VAAS compliance screening API.
    // The VAAS api will return a _signedMessage string, signed with VAAS private key, containing the address
    // that was screened, and the timestamp of when the screen was made.
    function validateAddress(
        address _screenedAddress,
        uint256 _vaasTimestamp,
        bytes memory _vaasHashSignature
    ) public view returns (bool) {
        // if the validation is disabled, always return true
        if(stopValidation)
            return true;

        require(_screenedAddress != address(0));
        require(
            (_vaasTimestamp + screeningTimeoutSeconds) > block.timestamp
        );

        // re-create the hash using the screened address and the timestamp, previously called at the vaas API
        bytes32 _messageHash = keccak256(abi.encodePacked(_screenedAddress, _vaasTimestamp));
        return _messageHash.toEthSignedMessageHash().recover(_vaasHashSignature) == vaasSignerAddress;            
    }

}
