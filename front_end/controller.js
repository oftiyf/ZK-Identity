import { buildMimc7 } from './lib/mimc7.js';
import { main } from './demogen.js';
import { callProverFunction } from './call.js';

async function processData(indexData) {
    try {
        // 构建 mimc7
        const mimc7 = await buildMimc7();

        // 从 indexData 中提取必要的数据
        const { secret, studentId, newnullifier } = indexData;

        // 1. 将 newnullifier 转换为 nullifierHash
        const nullifierHash = mimc7.hash(newnullifier);

        // 2. 创建 newcommitment
        const secretStudentHash = mimc7.hash(secret, studentId);
        const newcommitment = mimc7.hash(secretStudentHash, newnullifier);

        // 3. 准备传递给 demogen.js main 函数的输入
        const input = {
            root: indexData.root,
            nullifierHash,
            collegeId: indexData.collegeId,
            newcommitment,
            studentId,
            secret,
            pathElements: indexData.pathElements,
            pathIndices: indexData.pathIndices,
            newnullifier
        };
        //web测试用，不要真实使用
        const contractAddress = "0x6e838E26f3e9488a32651850A6EBd2f351d2E8AD";

        const result = await main(input);
        console.log("demogen.js main 函数的结果:", result);
        await callProverFunction(
            result.solidityInputfinal,
            contractAddress
        );
    } catch (error) {
        console.error("处理数据时出错:", error);
    }
}

// 示例用法
// processData(indexData); // 使用实际的 indexData 调用此函数
