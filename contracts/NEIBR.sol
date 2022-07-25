// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract NEIBR is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    uint8 public extra_fee_percent = 5;
    address private thirdPartyAddress = 0x;

    function initialize() initializer public {
        __ERC20_init("The Neighbor", "NEIBR");
        __ERC20Burnable_init();
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();

        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }

    mapping(address => bool) _isBlackListed;

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(amount>0, "Invalid amount entered");
        address owner = _msgSender();
        require(!_isBlackListed[to] || !_isBlackListed[owner], "This account is blacklisted");
        uint256 fee = (amount*extra_fee_percent)/100;
        _transfer(owner, thirdPartyAddress, fee);
        _transfer(owner, to, amount-fee);
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

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}