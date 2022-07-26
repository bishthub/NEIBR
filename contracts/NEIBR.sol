// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NEIBR is ERC20, ERC20Burnable, Pausable, Ownable {
    uint8 private extra_fee_percent = 5;
    address private thirdPartyAddress;

    constructor() ERC20("The Neighbour", "NEIBR") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
        thirdPartyAddress = msg.sender;
    }

    mapping(address => bool) _isBlackListed;

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(amount>0, "Invalid amount entered");
        address owner = _msgSender();
        require(!_isBlackListed[to] || !_isBlackListed[owner], "This account is blacklisted");
        uint256 fee = (amount*extra_fee_percent)/100;
        _transfer(owner, thirdPartyAddress, fee);
        _transfer(owner, to, amount-fee);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(amount>0, "Invalid amount entered");
        address spender = _msgSender();
        require(!_isBlackListed[to] || !_isBlackListed[from] || !_isBlackListed[spender], "This account is blacklisted");
        _spendAllowance(from, spender, amount);
        uint256 fee = (amount*extra_fee_percent)/100;
        _transfer(from, thirdPartyAddress, fee);
        _transfer(from, to, amount-fee);
        return true;
    }

    // add multiple accounts at a time to the blacklist by separating all of them with ',' (comma)
    function addToBlackList(address[] calldata accounts) external onlyOwner {
        for(uint256 i; i<accounts.length; ++i){
            _isBlackListed[accounts[i]] = true;
        } 
    }

    // remove single account at a time from the blacklist
    function removeFromBlackList(address account) external onlyOwner {
        _isBlackListed[account] = false;
    }

    // set extra_fee_percent
    function setExtraFee(uint8 fee_percent) external onlyOwner{
        extra_fee_percent = fee_percent;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}