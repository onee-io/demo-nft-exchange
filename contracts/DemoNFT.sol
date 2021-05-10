// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// 引入openzeppelin合约库
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DemoNFT is ERC721URIStorage {
    // 引用Counters工具类
    using Counters for Counters.Counter;

    // 定义全局唯一的ID
    Counters.Counter private _tokenIds;

    // 定义NFT资产名称
    constructor() ERC721("DemoNFT", "DNFT") {}

    // 铸造NFT
    function awardItem(address recipient, string memory tokenURI) public returns (uint256){
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}