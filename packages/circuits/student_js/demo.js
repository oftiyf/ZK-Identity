import { WitnessCalculator } from './witness_calculator.js';
import { generateWitnessFromFormat } from './generate_witness.js';
import * as snarkjs from 'snarkjs';

async function calculateWitness(input) {
    try {
        const response = await fetch('circuit.wasm');
        const wasmBuffer = await response.arrayBuffer();

        const wasmModule = await WebAssembly.compile(wasmBuffer);
        const instance = await WebAssembly.instantiate(wasmModule, {
            runtime: {
                exceptionHandler: () => {}
            }
        });

        const witnessCalculator = new WitnessCalculator(instance, true);
        const witness = await witnessCalculator.calculateWitness(input, false);

        return witness;
    } catch (error) {
        console.error("Witness calculation failed:", error);
        throw error;
    }
}

async function generateProof(input) {
    try {
        // 1. 首先获取 witness
        const witness = await calculateWitness(input);

        // 2. 使用 witness 生成 proof
        const { proof, publicSignals } = await snarkjs.groth16.prove(
            "circuit_final.zkey",  // 确保这个路径正确
            witness
        );

        return { proof, publicSignals };
    } catch (error) {
        console.error("Proof generation failed:", error);
        throw error;
    }
}

// 如果需要验证 proof
async function verifyProof(proof, publicSignals) {
    try {
        const vKey = await fetch("verification_key.json").then(res => res.json());
        const isValid = await snarkjs.groth16.verify(vKey, publicSignals, proof);
        return isValid;
    } catch (error) {
        console.error("Proof verification failed:", error);
        throw error;
    }
}

// 使用示例
async function main(input) {

    try {
        // 生成 proof
        const { proof, publicSignals } = await generateProof(input);
        console.log("Proof generated:", proof);
        console.log("Public signals:", publicSignals);



        // 如果需要将 proof 转换为适合智能合约的格式
        const solidityProof = [
            proof.pi_a[0], proof.pi_a[1],
            [proof.pi_b[0][1], proof.pi_b[0][0]],
            [proof.pi_b[1][1], proof.pi_b[1][0]],
            proof.pi_c[0], proof.pi_c[1]
        ];

        const solidityInputfinal = [
            solidityProof,
            publicSignals
        ]
        return {
            proof,
            publicSignals,
            isValid,
            solidityProof,
            solidityInputfinal
        };
    } catch (error) {
        console.error("Process failed:", error);
        throw error;
    }
}

// 导出需要的函数
export {
    calculateWitness,
    generateProof,
    verifyProof,
    main
};