async function callProverFunction(solidityInputfinal, contractAddress) {
    try {
        // 检查是否有钱包连接
        if (!window.ethereum) {
            throw new Error("请先安装 MetaMask!");
        }

        // 创建 provider
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        
        // 请求用户连接钱包
        await provider.send("eth_requestAccounts", []);
        
        // 获取 signer
        const signer = provider.getSigner();

        // 从 solidityInputfinal 中解构出所需参数
        const [solidityProof, publicSignals] = solidityInputfinal;
        const [root, nullifierHash, collegeId, newCommitment] = publicSignals;

        // 调用合约的 prover 函数
        // 创建合约实例
        const contract = new ethers.Contract(contractAddress, [
            'prover(uint256[8],bytes32,bytes32,uint256,bytes32,address)'
        ], signer);

        const tx = await contract.prover(
            solidityProof,
            root,
            nullifierHash,
            collegeId,
            newCommitment,
            await signer.getAddress(),
            {
                gasLimit: 1000000 // 根据需要调整 gas 限制
            }
        );

        // 等待交易完成
        const receipt = await tx.wait();
        console.log("交易成功:", receipt);
        return receipt;
    } catch (error) {
        console.error("调用合约失败:", error);
        throw error;
    }
}
