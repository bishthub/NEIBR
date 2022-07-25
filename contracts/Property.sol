// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract Property is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable, 
    PausableUpgradeable, OwnableUpgradeable, ERC721BurnableUpgradeable, UUPSUpgradeable, IERC20Upgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    mapping(uint8 => uint) public propertyPrice;

    function initialize() initializer public {
        __ERC721_init("The Property", "PRT");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __Pausable_init();
        __Ownable_init();
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();
        propertyPrice[0] = 5 ether;
        propertyPrice[1] = 10 ether;
        propertyPrice[2] = 20 ether;
    }

    uint currentTokenId;
    uint256 private constant MAX_SUPPLY = 5000;
    uint256 private constant MAX_PER_WALLET = 5;
    mapping(string => bool) uriIsPresent;
    mapping(uint => uint8) tokenProperty;
    mapping(address => bool) _isBlackListed;

    mapping(uint => string) idToUri;

    event Mint(
        address to,
        string uri
    );

    event Burn(
        uint tokenId
    );

    event Pause(
        bool state
    );

    function pause() public onlyOwner {
        _pause();
        emit Pause(true);
    }

    function unpause() public onlyOwner {
        _unpause();
        emit Pause(false);
    }

    function MintNFT(uint8 _property, string memory _uri, address _to) external payable whenNotPaused {
        require(!uriIsPresent[_uri], "This URI already exists");
        require(!_isBlackListed[_to], "This account is blacklisted");
        
        // any other conditions
        require(_property==0 || _property==1 || _property==2, "Enter a valid property");

        require(currentTokenId + 1 < MAX_SUPPLY, "Max supply exceeded");
        require(balanceOf(_to) < MAX_PER_WALLET, "Mint limit exceeded");

        require(msg.value == propertyPrice[_property], "Wrong Payment");
        safeMint(_to, currentTokenId, _uri);
        tokenProperty[currentTokenId] = _property;

        uriIsPresent[_uri] = true;
        idToUri[currentTokenId] = _uri;
        currentTokenId++;

        emit Mint(_to, _uri);
    }

    function exchangeWithToken(address tokenAddress, uint8 _property, string memory _uri, address _to) public {
        IERC20Upgradeable _tokenAddress = IERC20Upgradeable(tokenAddress);
        _tokenAddress.transferFrom(msg.sender, address(this), propertyPrice[_property]);
        safeMint(_to, currentTokenId, _uri);

        uriIsPresent[_uri] = true;
        idToUri[currentTokenId] = _uri;
        currentTokenId++;
    }

    function withdrawTokens(address tokenAddress) public onlyOwner {
        IERC20Upgradeable _tokenAddress = IERC20Upgradeable(tokenAddress);
        _tokenAddress.transfer(msg.sender, _tokenAddress.balanceOf(address(this)));
    }

    function safeMint(address to, uint256 tokenId, string memory uri) internal {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function getPropertyType(uint tokenId) public view returns(uint8) {
        require(_exists(tokenId), "Token id does not exist");
        return tokenProperty[tokenId];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

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

    function withdrawMoney(address payable acc1, address payable acc2) public onlyOwner {
        acc1.transfer(70*(address(this).balance)/100);
        acc2.transfer(address(this).balance);
    }

    function BurnNFT(uint tokenId) public whenNotPaused {
        require(msg.sender == owner() || msg.sender == ownerOf(tokenId), "You are not allowed");
        require(_exists(tokenId), "Token id does not exist");
        require(!_isBlackListed[msg.sender], "This account is blacklisted.");
        
        delete(uriIsPresent[tokenURI(tokenId)]);
        delete(tokenProperty[tokenId]);
        _burn(tokenId);
        emit Burn(tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}