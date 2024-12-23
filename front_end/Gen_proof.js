// 使用动态导入
let witnessCalculator;

/**
 * 从HTML表单获取输入数据
 * @returns {Object} 返回表单数据对象
 */
export function getInputDataFromForm() {
    return {
        root: document.getElementById('root').value,
        nullifierHash: document.getElementById('nullifierHash').value,
        collegeId: document.getElementById('collegeId').value,
        newcommitment: document.getElementById('newcommitment').value,
        studentId: document.getElementById('studentId').value,
        secret: document.getElementById('secret').value,
        pathElements: document.getElementById('pathElements').value.split(','),
        pathIndices: document.getElementById('pathIndices').value.split(','),
        nullifier: document.getElementById('nullifier').value
    };
}

/**
 * 生成证明所需的见证值
 * @param {Object} inputData - 输入数据对象
 * @returns {Promise<Object>} 返回计算得到的见证值
 */
export async function generateWitness(inputData) {
    try {
        // 动态导入 witness_calculator.js
        if (!witnessCalculator) {
            witnessCalculator = await import('../circuits/student_js/witness_calculator.js');
        }

        // 获取 WASM 代码
        const wasmResponse = await fetch('../circuits/student_js/student.wasm');
        const wasmCode = await wasmResponse.arrayBuffer();

        // 创建见证计算器实例
        const calculator = await witnessCalculator.default(wasmCode);

        // 验证输入数据格式
        const requiredFields = [
            'root',
            'nullifierHash',
            'collegeId',
            'newcommitment',
            'studentId',
            'secret',
            'pathElements',
            'pathIndices',
            'nullifier'
        ];

        for (const field of requiredFields) {
            if (!(field in inputData)) {
                throw new Error(`Missing required field: ${field}`);
            }
        }

        // 转换输入数据为 BigInt 格式
        const formattedInput = {
            root: [BigInt(inputData.root)],
            nullifierHash: [BigInt(inputData.nullifierHash)],
            collegeId: [BigInt(inputData.collegeId)],
            newcommitment: [BigInt(inputData.newcommitment)],
            studentId: [BigInt(inputData.studentId)],
            secret: [BigInt(inputData.secret)],
            pathElements: inputData.pathElements.map(el => BigInt(el)),
            pathIndices: inputData.pathIndices.map(idx => BigInt(idx)),
            nullifier: [BigInt(inputData.nullifier)]
        };

        // 计算见证值
        const witness = await calculator.calculateWTNSBin(formattedInput);
        return witness;

    } catch (error) {
        console.error('生��见证值时发生错误:', error);
        throw error;
    }
}
