pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

template MerkleTreeNode() {
    signal input left;
    signal input right;
    signal output hash;

    component hasher = Poseidon(2);
    hasher.inputs[0] <== left;
    hasher.inputs[1] <== right;
    hash <== hasher.out;
}

template StudentVerifier(merkleTreeDepth) {
    // 私有输入
    signal input studentId;    
    signal input secret;      
    signal input collegeKey;   
    signal input merklePathElements[merkleTreeDepth];
    signal input merklePathIndices[merkleTreeDepth];
    
    signal input collegeId;          
    signal input merkleRoot;        
    signal input validityTimestamp;   
    signal output commitment;        
    signal output nullifier;         

    // 1. 计算学生ID的哈希作为叶子节点
    component leafHasher = Poseidon(1);
    leafHasher.inputs[0] <== studentId;
    
    // 2. 验证merkle路径
    component nodes[merkleTreeDepth];
    component muxLeft[merkleTreeDepth];
    component muxRight[merkleTreeDepth];
    signal computedHash[merkleTreeDepth + 1];
    
    computedHash[0] <== leafHasher.out;
    
    for (var i = 0; i < merkleTreeDepth; i++) {
        nodes[i] = MerkleTreeNode();
        muxLeft[i] = Mux1();
        muxRight[i] = Mux1();
        muxLeft[i].s <== merklePathIndices[i];
        muxLeft[i].c[0] <== computedHash[i];
        muxLeft[i].c[1] <== merklePathElements[i];

        muxRight[i].s <== merklePathIndices[i];
        muxRight[i].c[0] <== merklePathElements[i];
        muxRight[i].c[1] <== computedHash[i];
        
        nodes[i].left <== muxLeft[i].out;
        nodes[i].right <== muxRight[i].out;
        
        computedHash[i + 1] <== nodes[i].hash;
    }
    
    computedHash[merkleTreeDepth] === merkleRoot;
    component collegeVerifier = Poseidon(2);
    collegeVerifier.inputs[0] <== studentId;
    collegeVerifier.inputs[1] <== collegeKey;

    component commitmentHasher = Poseidon(2);
    commitmentHasher.inputs[0] <== studentId;
    commitmentHasher.inputs[1] <== secret;
    commitment <== commitmentHasher.out;

    component nullifierHasher = Poseidon(2);
    nullifierHasher.inputs[0] <== secret;
    nullifierHasher.inputs[1] <== commitment;
    nullifier <== nullifierHasher.out;

    component timeCheck = GreaterEqThan(32);
    timeCheck.in[0] <== validityTimestamp;
    timeCheck.in[1] <== 0;
    timeCheck.out === 1;
}

component main {public [collegeId, merkleRoot, validityTimestamp]} = StudentVerifier(4);