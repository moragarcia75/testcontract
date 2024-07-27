// SPDX-License-Identifier: MIT
pragma solidity >=0.5.8 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @custom:security-contact MartianFroggies@outlook.com

contract MyTestToken is ERC721Enumerable, Ownable { 
    using Strings for uint256;
    
    uint256 public constant MAX_SUPPLY = 4;
    uint256 public constant MAX_PER_WALLET = 1;
    uint256 public constant PRICE = 0.002 ether;
    string public baseTokenURI;
    bool public paused = false;
    
    address public immutable ownerWallet = 0xF422e3780eC75A1F67297f373d372270C1905326; // Artist Wallet
    address public immutable nftHoldersWallet = 0xC6b1620495F577a1f7396C608d7F0AfcFd323e0c; // nftHolders wallet
    address public immutable philanthropicWallet = 0x5E116A5AF6A3cAb148bc249B682fEEb857563e12; // philanthropic wallet
    address public immutable cultDAOWallet = 0xCF1f230f817a799ba2F4C2Bf42ada73E0BBf48Cf; // cultDAO wallet
    address public immutable shibaInuWallet = 0x202826200a5994Ce551b4d7cEa977FDf46E32609; // SHIBA INU wallet

    constructor(string memory baseURI) ERC721("MyTestToken", "MTT") Ownable(msg.sender) {
        setBaseURI(baseURI); 
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function mint(uint256 _amount) public payable {
        uint256 totalMinted = totalSupply(); 
        require(!paused, "Minting is paused");
        require(_amount > 0 && _amount <= MAX_PER_WALLET, "Cannot mint specified number of NFTs");
        require(totalMinted + _amount <= MAX_SUPPLY, "Minting would exceed max supply");
        require(balanceOf(msg.sender) + _amount <= MAX_PER_WALLET, "Exceeds maximum NFTs per wallet"); 
        require(msg.value >= PRICE * _amount, "Ether sent is not correct");
        
        for (uint256 i = 0; i < _amount; i++) {
            _safeMint(msg.sender, totalMinted + i);
        }

        // Split payments
        uint256 totalAmount = msg.value;
        uint256 ownerShare = (totalAmount * 75) / 100;
        uint256 nftHoldersShare = (totalAmount * 10) / 100;
        uint256 philanthropicShare = (totalAmount * 5) / 100;
        uint256 cultDAOshare = (totalAmount * 5) / 100; 
        uint256 shibaInuShare = (totalAmount * 5) / 100; 

        _safeTransfer(nftHoldersWallet, nftHoldersShare);
        _safeTransfer(ownerWallet, ownerShare);
        _safeTransfer(philanthropicWallet, philanthropicShare);
        _safeTransfer(cultDAOWallet, cultDAOshare);
        _safeTransfer(shibaInuWallet, shibaInuShare);
    }

    function _safeTransfer(address to, uint256 amount) private {
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function pause(bool _state) public onlyOwner { 
        paused = _state;
    }

    function withdraw() public onlyOwner {
        _safeTransfer(owner(), address(this).balance);
        pause(true);
    }

    function unpauseMinting() public onlyOwner {
        pause(false);
    }
}

