// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// 交易所合约
contract Exchange {

    // 出售中的商品列表
    uint[] public tokenIds;

    // 获取所有出售中的NFT
    function getAllTokenId() external view returns (uint[] memory) {
        return tokenIds;
    }

    // 上架商品
    function putOnNFT(uint tokenId) public returns (uint) {
        // require 操作者应为nft的所有者 TODO
        tokenIds.push(tokenId);
        return tokenId;
    }

    fallback() external payable {
    }
}