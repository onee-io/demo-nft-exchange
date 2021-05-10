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

            </Content>

            <Footer class="layout-footer-center">&copy; 2021 北京球秘科技有限公司</Footer>
        </Layout>

        <Modal v-model="uploadModal" title="上传收藏品" @on-ok="uploadCollection" @on-cancel="closeUploadModal" ok-text="上传">
            <Upload v-if="!collectionData.image" type="drag" :before-upload="uploadImage" action="https://api.pinata.cloud/pinning/pinFileToIPFS">
                <div style="padding: 20px 0">
                    <Icon type="ios-cloud-upload" size="52" style="color: #3399ff"></Icon>
                    <p>点击上传收藏品图片</p>
                </div>
            </Upload>
            <div v-if="collectionData.image" style="text-align:center">
                <img :src="collectionData.image" class="collection-image">
            </div>
            <Form ref="collectionData" :model="collectionData" :rules="collectionDataRule" :label-width="60">
                <FormItem label="名称" prop="name">
                    <Input type="text" v-model="collectionData.name" placeholder="请输入收藏品名称"></Input>
                </FormItem>
                <FormItem label="链接" prop="external_url">
                    <Input type="url" v-model="collectionData.external_url" placeholder="请输入收藏品链接（可选）"></Input>
                </FormItem>
                <FormItem label="描述" prop="description">
                    <Input type="textarea" v-model="collectionData.description" placeholder="请输入收藏品描述（可选）"></Input>
                </FormItem>
            </Form>
        </Modal>
    </div>
</template>

<script>
import Web3 from 'web3';
import contract from 'truffle-contract';
import nft from '../../build/contracts/DemoNFT.json';
import exchange from '../../build/contracts/Exchange.json';
import pinataSDK from '@pinata/sdk';
// import fs from 'fs';

export default {
    name: "Exchange",
    data () {
        return {
            // 当前钱包地址
            account: null,
            // 合约持有者，可以提取合约中资金
            isOwner: false, 
            // 上传收藏品表单
            uploadModal: false,
            // 收藏品数据
            collectionData: {},
            collectionDataRule: {
                // name: [
                //     { required: true, message: '收藏品名称不可为空', trigger: 'blur' }
                // ]
            }
        }
    },

    // 初始化Hook函数
    async created () {
        // 清空收藏品表单
        this.cleanCollectionData();
        // 初始化IPFS客户端
        this.initIpfsClient();
        // 连接钱包
        await this.linkWallet();
        // 加载全部收藏品
        this.loadAllCollection();
    },

    methods: {

        // 清空收藏品数据
        cleanCollectionData() {
            this.collectionData =  {
                name: null,
                external_url: null,
                description: null,
                image: null
            }   
        },

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
        loadAllCollection () {
            // TODO 与交易所合约交互
            console.log('加载全部收藏品');
        },

        // 显示上传收藏品模态框
        showUploadModal() {
            this.uploadModal = true;
        },

        // 关闭上传收藏品模态框
        closeUploadModal() {
            this.uploadModal = false;
            this.cleanCollectionData();
        },

        loadTextFromFile(ev) {
            console.log(ev);
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
            this.showSpin('创建中，请稍候...');
            console.log(this.collectionData);
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
                console.log('mintResult', mintResult);
                let uri = await this.nftInstance.tokenURI(mintResult.receipt, { from: this.account });
                console.log('uri', uri);
                this.closeSpin();
                this.$Message.success('上传成功');
            } catch (error) {
                this.cleanCollectionData();
                console.log(error);
                this.closeSpin();
                this.$Message.error('上传失败');
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
</style>