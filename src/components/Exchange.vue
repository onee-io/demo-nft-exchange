<template>
    <div class="layout">
        <Layout>
            <Header>
                <div class="layout-header-logo">NFT 交易所（演示版）</div>
                <div class="layout-nav">
                    <!-- 已连接钱包 -->
                    <div v-if="account" class="header-operate">
                        <span class="header-text">{{ account }}</span>
                        <Button type="success" shape="circle" icon="md-cloud-upload" @click="showUploadModal">上传收藏品</Button>
                    </div>
                    <!-- 未连接钱包 -->
                    <div v-if="!account" class="header-operate">
                        <Button type="info" shape="circle" icon="logo-octocat" @click="linkWallet">连接MetaMask钱包</Button>
                    </div>
                </div>
            </Header>

            <Content>
                <div class="collection-card-wrapper">
                    <div v-for="data in collectionList" :key="data.name" class="collection-card">
                        <Card>
                            <p slot="title">{{data.name}}</p>
                            <p slot="extra">#{{data.tokenId}}</p>
                            <img :src="data.image" class="collection-card-image">
                            <p v-if="data.description">描述：{{data.description}}</p>
                            <p>价格：{{data.price ? data.price : 0}}&nbsp;Ether</p>
                            <Button v-if="data.isOwner" type="info" long @click="showPresentModal(data.tokenId)">赠送</Button>
                            <Button v-if="!data.isOwner" type="success" long @click="purchaseCollection(data.tokenId)">购买</Button>
                        </Card>
                    </div>
                    <div v-for="i in 8" :key="i" class="collection-card-empty" style="visibility: hidden"></div><!-- 空占位块 -->
                </div>
            </Content>

            <Footer class="layout-footer-center">&copy; 2021 北京球秘科技有限公司</Footer>
        </Layout>

        <!-- 上传收藏品模态框 -->
        <Modal v-model="uploadModal" title="创建收藏品" @on-cancel="closeUploadModal">
            <Upload v-if="!collectionData.image" type="drag" :before-upload="uploadImage" action="https://api.pinata.cloud/pinning/pinFileToIPFS">
                <div style="padding: 20px 0">
                    <Icon type="ios-cloud-upload" size="52" style="color: #3399ff"></Icon>
                    <p>点击上传收藏品图片</p>
                </div>
            </Upload>
            <div v-if="collectionData.image" style="text-align:center">
                <img :src="collectionData.image" class="collection-image">
            </div>
            <Form ref="collectionData" :model="collectionData" :label-width="60">
                <FormItem label="名称" prop="name">
                    <Input type="text" v-model="collectionData.name" placeholder="请输入收藏品名称"></Input>
                </FormItem>
                <FormItem label="描述" prop="description">
                    <Input type="textarea" v-model="collectionData.description" placeholder="请输入收藏品描述（可选）"></Input>
                </FormItem>
                <FormItem label="价格" prop="price">
                    <Input type="number" v-model="collectionData.price" placeholder="请输入收藏品价格"  style="width: auto"></Input>&nbsp;Ether
                </FormItem>
            </Form>
            <div slot="footer">
                <Button type="success" size="large" long @click="uploadCollection">创建收藏品</Button>
            </div>
        </Modal>

        <!-- 赠送收藏品模态框 -->
        <Modal v-model="presentModal" title="赠送收藏品" @on-ok="presentCollection" @on-cancel="closePresentModal" ok-text="赠送">
            <Form ref="presentData" :model="presentData" :label-width="80">
                <FormItem label="接收地址" prop="address">
                    <Input type="text" v-model="presentData.address" placeholder="请输入收藏品接收地址"></Input>
                </FormItem>
            </Form>
            <div slot="footer">
                <Button type="info" size="large" long @click="presentCollection">赠送收藏品</Button>
            </div>
        </Modal>
    </div>
</template>

<script>
import Web3 from 'web3';
import contract from 'truffle-contract';
import nft from '../../build/contracts/DemoNFT.json';
import exchange from '../../build/contracts/Exchange.json';
import pinataSDK from '@pinata/sdk';

export default {
    name: "Exchange",
    data () {
        return {
            // 当前钱包地址
            account: null,
            // 合约持有者，可以提取合约中资金
            isOwner: false, 
            // 收藏品列表
            collectionList: [],
            collectionPriceMap: {},
            // 上传收藏品
            uploadModal: false,
            collectionData: {
                image: null,
                name: null,
                description: null,
                price: null
            },
            // 赠送收藏品
            presentModal: false,
            presentData: {
                tokenId: null,
                address: null
            }
        }
    },

    // 初始化Hook函数
    async created () {
        // 初始化IPFS客户端
        this.initIpfsClient();
        // 连接钱包
        await this.linkWallet();
        // 加载全部收藏品
        await this.loadAllCollection();
    },

    methods: {

        // 初始化IPFS客户端
        initIpfsClient () {
            this.pinata = pinataSDK(global.IPFS_API_KEY, global.IPFS_API_SECRET);
        },

        // 连接钱包
        async linkWallet () {
            // 初始化web3及账号
            // if (window.ethereum) {
            //     this.provider = window.ethereum;
            //     // 请求用户授权
            //     await window.ethereum.request({ method: 'eth_requestAccounts'});
            // } else if (window.web3) {
            //     this.provider = window.web3.currentProvider;
            // } else {
            //     this.$Message.error('请安装MetaMask插件并解锁您的以太坊账户');
            // }
            this.provider = new Web3.providers.HttpProvider("http://127.0.0.1:7545"); // 本地调试环境
            this.web3 = new Web3(this.provider);
            this.web3.eth.getAccounts().then(accounts => this.account = accounts[0]);
            // 初始化NFT合约实例
            const nftContract = contract(nft);
            nftContract.setProvider(this.provider);
            this.nftInstance = await nftContract.deployed();
            // 初始化交易所合约实例
            const exchangeContract = contract(exchange);
            exchangeContract.setProvider(this.provider);
            this.exchangeInstance = await exchangeContract.deployed();
        },

        // 加载全部收藏品
        async loadAllCollection () {
            // TODO 与交易所合约交互
            let tokenIds = await this.exchangeInstance.getAllTokenId({from: this.account});
            this.collectionList = [];
            tokenIds.forEach(async tokenId => {
                let tokenURI = await this.nftInstance.tokenURI(tokenId, {from: this.account});
                let result = await this.$http.get(tokenURI);
                let metaData = result.data;
                metaData['tokenId'] = tokenId;
                metaData['tokenURI'] = tokenURI;
                let ownerAddress = await this.nftInstance.ownerOf(tokenId, {from: this.account});
                metaData['isOwner'] = this.account == ownerAddress;
                console.log(metaData);
                this.collectionList.push(metaData);
                this.collectionPriceMap[tokenId] = metaData.price;
                console.log(this.collectionPriceMap);
            });
        },

        // 显示上传收藏品模态框
        showUploadModal() {
            this.uploadModal = true;
        },

        // 关闭上传收藏品模态框
        closeUploadModal() {
            this.uploadModal = false;
            this.cleanCollectionData();
            this.closeSpin();
        },

        // 上传图片
        uploadImage(file) {
            console.log(file);
            // var fs = require('fs');
            // console.log('fs', fs);
            // var readableStreamForFile = fs.createReadStream('../assets/logo.png');
            // var options = {
            //     pinataMetadata: {
            //         name: file.name
            //     }
            // };
            // this.pinata.pinFileToIPFS(file, options).then((result) => {
            //     console.log(result);
            // }).catch((err) => {
            //     console.log(err);
            // });
            // TODO 上传图片到IPFS 此处为临时演示写死
            this.collectionData.image = global.IPFS_HOST + "QmZZeMZJsLHPMcwPP3gMZkBXQtaiscSJjfeL6CR3WD5Zh1";
            return false;
        },

        // 上传收藏品
        async uploadCollection() {
            if (this.collectionData.image == null) {
                this.$Message.error("请上传收藏品图片");
                return;
            }
            if (this.collectionData.name == null) {
                this.$Message.error("请输入收藏品名称");
                return;
            }
            if (this.collectionData.price == null) {
                this.$Message.error("请设定收藏品价格");
                return;
            }
            this.showSpin('创建中，请稍候...');
            const options = {
                pinataMetadata: {
                    name: this.collectionData.name + '.json'
                }
            };
            try {
                let uploadResult = await this.pinata.pinJSONToIPFS(this.collectionData, options);
                console.log('uploadResult', uploadResult);
                let tokenURI = global.IPFS_HOST + uploadResult.IpfsHash;
                // 合约交互 铸造NFT
                let mintResult = await this.nftInstance.awardItem(this.account, tokenURI, { from: this.account });
                let tokenId = mintResult.receipt.logs[0].args.tokenId;
                console.log('mintResult', mintResult);
                console.log('tokenId', tokenId);
                // 合约交互 授权交易所账号可操作此NFT
                let approveResult = await this.nftInstance.approve(global.MANAGER_ADDRESS, tokenId, {from: this.account});
                console.log('approveResult', approveResult);
                // 合约交互 上架NFT
                let putResult = await this.exchangeInstance.putOnNFT(tokenId, {from: this.account});
                console.log('putResult', putResult);
                this.closeUploadModal();
                this.loadAllCollection();
                this.$Message.success('创建成功');
            } catch (error) {
                console.log(error);
                this.closeUploadModal();
                this.loadAllCollection();
                this.$Message.error('创建失败');
            }
        },

        // 清空收藏品数据
        cleanCollectionData() {
            this.collectionData =  {
                image: null,
                name: null,
                description: null,
                price: null
            }
        },

        // 显示赠送收藏品模态框
        showPresentModal(tokenId) {
            this.presentData.tokenId = tokenId;
            this.presentModal = true;
        },

        // 关闭赠送收藏品模态框
        closePresentModal() {
            this.presentModal = false;
            this.cleanPresentData();
            this.closeSpin();
        },

        // 赠送收藏品
        async presentCollection() {
            if (this.presentData.address == null) {
                this.$Message.error("请填写接收地址");
                return;
            }
            this.showSpin('交易中，请稍候...');
            try {
                let result = await this.nftInstance.safeTransferFrom(this.account, this.presentData.address, this.presentData.tokenId, {from: this.account});
                console.log(result);
                this.closePresentModal();
                this.loadAllCollection();
                this.$Message.success('赠送成功');
            } catch (error) {
                console.log(error);
                this.closePresentModal();
                this.loadAllCollection();
                this.$Message.error('赠送失败');
            }
        },

        // 清空赠送数据
        cleanPresentData() {
            this.presentData = {
                tokenId: null,
                address: null
            }
        },

        // 购买收藏品
        async purchaseCollection(tokenId) {
            console.log(tokenId);
            this.showSpin('交易中，请稍候...');
            try {
                let result = await this.web3.eth.sendTransaction({
                    from: this.account,
                    to: this.exchangeInstance.address,
                    value: this.web3.utils.toWei(this.collectionPriceMap[tokenId])
                });
                console.log('支付结果', result);
                // TODO 通知服务端转账成功 发起NFT所有权转移
                this.closeSpin();
                this.$Message.success('交易成功');
            } catch (error) {
                console.log(error);
                this.closeSpin();
                this.$Message.error('交易失败');
            }
        },

        // 展示全局加载页
        showSpin(text) {
            this.$Spin.show({
                render: (h) => {
                    return h('div', [
                        h('Icon', {
                            'class': 'spin-icon-load',
                            props: {
                                type: 'ios-loading',
                                size: 32
                            }
                        }),
                        h('div', text)
                    ])
                }
            });
        },

        // 关闭全局加载页
        closeSpin() {
            this.$Spin.hide();
        }
    }
}
</script>

<style>
.layout {
    border: 1px solid #d7dde4;
    background: #f5f7f9;
    position: relative;
    border-radius: 4px;
    overflow: hidden;
}
.layout-header-logo {
    float: left;
    font-size: 20px;
    color: #fff;
}
.layout-footer-center {
    text-align: center;
}
.header-operate {
    float: right;
}
.header-text {
    margin-right: 20px;
    font-size: 14px;
    color: #fff;
}
.spin-icon-load{
    animation: ani-demo-spin 1s linear infinite;
}
.collection-image {
    width: 50%;
    margin-bottom: 20px;
    border-radius: 10px;
    border: 1px solid #eee;
}
.collection-card-wrapper {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
    height: auto;
    display: -webkit-flex;
    justify-content: space-between;
    flex-direction: row;
}
.collection-card {
    flex: 0 0 240px;
    margin: 20px auto;
}
.collection-card-empty {
    flex: 0 0 240px;
    margin: 20px auto;
    height: 0px;
}
.collection-card-image {
    width: 100%;
    border-radius: 10px;
    border: 1px solid #eee;
}
</style>