const wc  = require("./witness_calculator.js");
const { readFileSync, writeFile } = require("fs");

// 检查命令行参数是否正确
// 需要三个参数：
// 1. .wasm 文件 - 编译后的电路文件
// 2. input.json - 输入参数文件
// 3. output.wtns - 输出的 witness 文件
if (process.argv.length != 5) {
    console.log("使用方法: node generate_witness.js <file.wasm> <input.json> <output.wtns>");
} else {
    // 读取并解析输入的 JSON 文件
    // input.json 中需要包含电路所需的所有输入参数
    const input = JSON.parse(readFileSync(process.argv[3], "utf8"));
    
    // 读取编译后的 WebAssembly 文件
    const buffer = readFileSync(process.argv[2]);
    wc(buffer).then(async witnessCalculator => {
        // 计算 witness
        const w = await witnessCalculator.calculateWitness(input,0);
        
        // 将 witness 转换为二进制格式并保存到文件
        const buff = await witnessCalculator.calculateWTNSBin(input,0);
        writeFile(process.argv[4], buff, function(err) {
            if (err) throw err;
        });
    });
}
