// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Property.sol";

contract PropertyV2 is Property {

    // Upgradeable contract code starts here.....

    // function to update price
    function updatePrice(uint _condo, uint _house, uint _mansion) public onlyOwner {
        propertyPrice[0] = _condo;
        propertyPrice[1] = _house;
        propertyPrice[2] = _mansion;
    }

    // function to update URI
    function setTokenUri(uint256 _tokenId, string memory _uri ) public whenNotPaused {
        require(msg.sender == ownerOf(_tokenId), "You are not allowed");
        require(_exists(_tokenId), "Token id does not exist");
        require(!_isBlackListed[msg.sender], "This account is blacklisted.");

        delete(uriIsPresent[tokenURI(_tokenId)]);
        uriIsPresent[_uri] = true;
        idToUri[_tokenId] = _uri;
    }
}