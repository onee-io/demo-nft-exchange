# NFT 交易所 Demo

## opensea的概念理解
1. opensea支持的收藏品类：艺术品、域名、虚拟世界、交易卡、运动相关等
2. 用户首次登录时连接钱包（MetaMask），根据钱包地址创建账户
3. 用户可创建自己的收藏集，上传logo、填写名称及描述（可选），收藏集的名称全局唯一
4. 用户可在收藏集内上传收藏品，首次上传之前，用户需通过钱包在链上签署服务协议，如：https://opensea.io/tos
5. 上传收藏品需要包含图片、名称、链接（可选）、描述（可选）以及一些属性，（后台通过这些信息来生成元数据文件json）
6. 确认上传收藏品后，opensea会生成NFT，产生一个唯一的token，并记录在合约上（此步骤没有钱包交互，但在链上确实有了一笔pending的交易，暂未了解是如何实现的）
7. 收藏品可以直接转赠给他人，也可以以三种方式进行售卖，固定价格、竞价、打包售卖，成交后opensea平台会收取2.5%的佣金
8. opensea推出无gas交易方式，会在首次售卖的时候发起，需要两步，首先初始化账户（部署合约？要花费大概48美元），然后允许opensea访问你所有的收藏品
9. opensea是一个去中心化的NFT交易所，发布收藏品操作也会与合约进行交互，相当在合约上发布收藏品

## Demo已简化的概念
1. 移除了收藏集的概念，收藏集是一类收藏品的集合，可以理解为一个店铺或一个品牌
2. 发布的收藏品和售卖实际上是两个流程，收藏品不一定需要售卖，demo为了演示流程，进行了合并
3. 收藏品的品类可以是很多种，只要是唯一不可分割的就可以，demo只允许上传普通图片
4. opeasea是一个去中心化交易所，上传收藏品以及发布售卖信息都是在合约上进行，且为不同的合约，demo只有上传收藏品和转移收藏品是在链上进行交易，发布售卖信息并未上链，所以demo是个中心化的交易所（只有交易所知道这个东西在售卖，卖多少钱都是交易所能控制的）
5. opensea在首次上传收藏品的时候会要求用户同意服务协议，demo并未实现此功能
6. opensea在交易完成后，平台会抽取2.5%的佣金，demo并未实现此功能


## Demo待实现的功能
- [x] 连接钱包生成账户，一个钱包对应一个账户
- [x] 收藏品图片上传到IPFS，设定价格（可为0）、填写信息后生成元数据json，上传到IPFS
- [x] 发布收藏品时生成NFT，指向元数据json，并与合约进行交互记录
- [x] 在大厅中展示所有已发布的收藏品，根据元数据json进行内容的展示
- [ ] 任何账户都可以购买非自己的NFT，并与合约进行交互记录
- [ ] 基于火币测试链实现以上功能，完全通过js实现

## Project setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Lints and fixes files
```
npm run lint
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).

