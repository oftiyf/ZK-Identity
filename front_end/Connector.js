const { Web3 } = require('web3');

// 连接到Sepolia测试网
const web3 = new Web3('https://sepolia.infura.io/v3/7b81620a6ae44972b31e1ebeeaba1b7c');

async function getBalance(address) {
    try {
        // 获取余额（返回值是wei）
        const balanceWei = await web3.eth.getBalance(address);
        
        const balanceEth = web3.utils.fromWei(balanceWei, 'ether');
        
        console.log(`地址 ${address} 的余额是: ${balanceEth} ETH`);
    } catch (error) {
        console.error('获取余额时出错:', error);
    }
}

const address = '';
getBalance(address);