// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract MyToken is ERC20, Ownable, ERC20Permit, ERC721Holder {
    IERC721 public collection;
    uint256 public tokenId;
    bool public initialized = false;

     constructor(
        string memory _name, 
        string memory _symbol, 
        address initialOwner
    ) 
        ERC20(_name, _symbol) 
        Ownable(initialOwner) 
        ERC20Permit(_name) 
    {}

    function initialize(address _collection, uint256 _tokenId, uint256 _amount) external onlyOwner {
        require(!initialized, "Already initialized");
        require(_amount > 0);
        collection = IERC721(_collection);
        collection.safeTransferFrom(msg.sender, address(this), _tokenId);
        tokenId = _tokenId;
        initialized = true;
        _mint(address(this), _amount); 
    }

    function buy(uint256 _amount) external payable {
        require(initialized, "Contract is not initialized");
        require(msg.value > 0, "Send some MATIC");
        uint256 tokenPrice = _amount;
        require(msg.value >= tokenPrice, "Insufficient MATIC sent");

        _transfer(address(this), msg.sender, _amount);
        payable(owner()).transfer(msg.value); 
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance); 
    }

    receive() external payable {}
} 