pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/mimc.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template HashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    component hasher = MiMC7(2);
    hasher.x_in <== left;
    hasher.k <== right;
    hash <== hasher.out;
}

template MerkleTreeChecker(levels) {
    signal input leaf;
    signal input root;
    signal input pathElements[levels];
    signal input pathIndices[levels];


    component selectors[levels];
    component hashers[levels];

    signal currentHash[levels + 1];
    currentHash[0] <== leaf;

    for (var i = 0; i < levels; i++) {
        selectors[i] = Selector();
        selectors[i].in[0] <== currentHash[i];
        selectors[i].in[1] <== pathElements[i];
        selectors[i].s <== pathIndices[i];

        hashers[i] = HashLeftRight();
        hashers[i].left <== selectors[i].out[0];
        hashers[i].right <== selectors[i].out[1];

        currentHash[i + 1] <== hashers[i].hash;
    }

    root === currentHash[levels];
}

template Selector() {
    signal input in[2];
    signal input s;
    signal output out[2];

    s * (1 - s) === 0;
    out[0] <== (in[1] - in[0])*s + in[0];
    out[1] <== (in[0] - in[1])*s + in[1];
}


template MiMC7Hash3() {
    signal input in1;
    signal input in2;
    signal input in3;
    signal output out;

    // 第一次哈希：hash(in1, in2)
    component hasher1 = MiMC7(2);
    hasher1.x_in <== in1;
    hasher1.k <== in2;

    // 第二次哈希：hash(hash(in1, in2), in3)
    component hasher2 = MiMC7(2);
    hasher2.x_in <== hasher1.out;
    hasher2.k <== in3;

    // 输出最终哈希值
    out <== hasher2.out;
}

template CommitmentHasher() {
    signal input nullifier;
    signal input secret;
    signal input studentid;
    signal output commitment;
    signal output nullifierHash;

    // 使用MiMC7计算commitment (commitment = hash(nullifier, secret))
    component commitmentHasher = MiMC7Hash3();
    commitmentHasher.in1 <== secret;
    commitmentHasher.in2 <== studentid;
    commitmentHasher.in3 <== nullifier;
    commitment <== commitmentHasher.out;

    // 使用MiMC7计算nullifierHash (nullifierHash = hash(nullifier))
    component nullifierHasher = MiMC7(1);
    nullifierHasher.x_in <== nullifier;
    nullifierHasher.k <== 0;  // 使用0作为第二个输入
    nullifierHash <== nullifierHasher.out;
}

template Student(levels) {
    signal input root;          
    signal input nullifierHash; 
    signal input collegeId;  
    signal input newcommitment; 
    
    signal input studentId;
    signal input secret;
    signal input pathElements[levels];
    signal input pathIndices[levels];
    signal input nullifier;
//下面检查提供的nullifierhash和隐私输入的nullifier是否正确符合，并生成commitment
    component hasher = CommitmentHasher();
    hasher.nullifier <== nullifier;
    hasher.secret <== secret;
    hasher.studentid <== studentId;
    hasher.nullifierHash === nullifierHash;
// 检查新的commitment不能与旧的commitment相同
    signal diff;
    diff <== hasher.commitment - newcommitment;

    component isZero = IsZero();
    isZero.in <== diff;
    1 - isZero.out === 1; // 确保diff不为0
//下面检查是否在哈希树里面
    component tree = MerkleTreeChecker(levels);
    tree.leaf <== hasher.commitment;
    tree.root <== root;
    for (var i = 0; i < levels; i++) {
        tree.pathElements[i] <== pathElements[i];
        tree.pathIndices[i] <== pathIndices[i];
    }

    signal collegeIdSquare;
    collegeIdSquare <== collegeId * collegeId;
}

component main {public [root, nullifierHash, collegeId,newcommitment]} = Student(20);