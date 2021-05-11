// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// 交易所合约
contract Exchange {

    // 出售中的商品列表
    uint[] public tokenIds;
    // 商品价格映射
    mapping(uint => uint) public tokenPriceMap;

    // 获取所有出售中的NFT
    function getAllTokenId() external view returns (uint[] memory) {
        return tokenIds;
    }

    // 上架商品
    function putOnNFT(uint tokenId, uint price) public returns (uint) {
        // require 操作者应为nft的所有者 TODO
        tokenIds.push(tokenId);
        tokenPriceMap[tokenId] = price;
        return tokenId;
    }

    // 交易放行
    function tradePass(uint tokenId, address payable to) public {
        // 抽取10%的佣金
        require(tokenPriceMap[tokenId] > 0, 'Token is not exsit');
        require(address(this).balance > 0, 'Contract have not ether');
        // TODO 不可重复转账 demo 不做限制
        to.transfer(SafeMath.mul(SafeMath.div(tokenPriceMap[tokenId], 10), 9));
    }

    receive () payable external {}

    fallback() external payable {}
}