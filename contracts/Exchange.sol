// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// 交易所合约
contract Exchange {

    // 出售中的商品列表
    string[] public goodsList;

    // 上架商品
    function putOnGoods(string memory tokenURI) public returns (string memory) {
        // require 操作者应为nft的所有者 TODO
        goodsList.push(tokenURI);
        return tokenURI;
    }
}