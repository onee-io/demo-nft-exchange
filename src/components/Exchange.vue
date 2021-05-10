<template>
    <div class="layout">
        <Layout>
            <Header>
                <div class="layout-header-logo">NFT 交易所（演示版）</div>
                <div class="layout-nav">
                    <!-- 已连接钱包 -->
                    <div v-if="account" class="header-operate">
                        <span class="header-text">{{ account }}</span>
                        <Button type="success" shape="circle" icon="md-cloud-upload" @click="updateCollection">上传收藏品</Button>
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
    </div>
</template>

<script>
import Web3 from "web3";
import contract from "truffle-contract";
import nft from '../../build/contracts/DemoNFT.json';
import exchange from '../../build/contracts/Exchange.json';

export default {
    name: "Exchange",
    data () {
        return {
            account: null,
            isOwner: false, // 合约持有者，可以提取合约中资金
        }
    },

    // 初始化Hook函数
    created () {
        // 连接钱包
        this.linkWallet();
        // 更新收藏品大厅
        this.updateCollection();
    },

    methods: {
        // 连接钱包
        linkWallet () {
            // 初始化web3及账号
            // if (window.ethereum) {
            //     this.provider = window.ethereum;
            //     // 请求用户授权
            //     let that = this;
            //     window.ethereum.request({ method: 'eth_requestAccounts'}).then(function(accounts) {
            //         that.account = accounts[0];
            //     }).catch(function(error) {
            //         if (error.code == 4001) {
            //             // 用户不授权时
            //             that.$Message.error("您拒绝了连接钱包账号");
            //         }
            //     });
            // } else if (window.web3) {
            //     this.provider = window.web3.currentProvider;
            // } else {
            //     this.$Message.error('请安装MetaMask插件并解锁您的以太坊账户');
            // }
            this.provider = new Web3.providers.HttpProvider("http://127.0.0.1:7545"); // 本地调试环境
            this.web3 = new Web3(this.provider);
            this.web3.eth.getAccounts().then(accounts => this.account = accounts[0]); // 本地调试环境
            // 初始化NFT合约实例
            const nftContract = contract(nft);
            nftContract.setProvider(this.provider);
            this.nftInstance = nftContract.deployed();
            // 初始化交易所合约实例
            const exchangeContract = contract(exchange);
            exchangeContract.setProvider(this.provider);
            this.exchangeInstance = exchangeContract.deployed();
        },

        // 获取合约信息
        updateCollection () {
            // this.$Message.info('测试全局消息提示');
        },
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
/* .layout-nav {
    width: 420px;
    margin: 0 auto;
    margin-right: 0px;
} */
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
</style>