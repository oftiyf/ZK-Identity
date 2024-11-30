pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/pedersen.circom";
include "../node_modules/circomlib/circuits/mimc.circom";  // 改用mimc

template HashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    component hasher = MiMC7(2);
    hasher.x_in <== left;
    hasher.k <== right;
    hash <== hasher.out;  // MiMC7使用x_in, k和out作为信号名
}

template DualMux() {
    signal input in[2];
    signal input s;
    signal output out[2];

    s * (1 - s) === 0;
    out[0] <== (in[1] - in[0])*s + in[0];
    out[1] <== (in[0] - in[1])*s + in[1];
}

template MerkleTreeChecker(levels) {
    signal input leaf;
    signal input root;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    component selectors[levels];
    component hashers[levels];

    for (var i = 0; i < levels; i++) {
        selectors[i] = DualMux();
        selectors[i].in[0] <== i == 0 ? leaf : hashers[i - 1].hash;
        selectors[i].in[1] <== pathElements[i];
        selectors[i].s <== pathIndices[i];

        hashers[i] = HashLeftRight();
        hashers[i].left <== selectors[i].out[0];
        hashers[i].right <== selectors[i].out[1];
    }

    root === hashers[levels - 1].hash;
}

template StudentCommitmentHasher() {
    signal input studentId;
    signal input secret;
    signal output commitment;
    signal output studentIdHash;

    component commitmentHasher = Pedersen(496);
    component studentIdHasher = Pedersen(248);
    component studentIdBits = Num2Bits(248);
    component secretBits = Num2Bits(248);
    
    studentIdBits.in <== studentId;
    secretBits.in <== secret;
    
    for (var i = 0; i < 248; i++) {
        studentIdHasher.in[i] <== studentIdBits.out[i];
        commitmentHasher.in[i] <== studentIdBits.out[i];
        commitmentHasher.in[i + 248] <== secretBits.out[i];
    }

    commitment <== commitmentHasher.out[0];
    studentIdHash <== studentIdHasher.out[0];
}

template StudentVerifier(levels) {
    // 公开输入
    signal input root;         // Merkle树根
    signal input collegeId;    // 学院ID
    signal input studentIdHash;// 学生ID哈希
    signal input studentId;
    signal input secret;
    signal input collegeKey;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    signal output commitment;
    signal output nullifier;
    component hasher = StudentCommitmentHasher();
    hasher.studentId <== studentId;
    hasher.secret <== secret;
    hasher.studentIdHash === studentIdHash;
    commitment <== hasher.commitment;

    component tree = MerkleTreeChecker(levels);
    tree.leaf <== hasher.commitment;
    tree.root <== root;
    for (var i = 0; i < levels; i++) {
        tree.pathElements[i] <== pathElements[i];
        tree.pathIndices[i] <== pathIndices[i];
    }

    component nullifierHasher = Pedersen(496);
    component nullifierInputBits = Num2Bits(248);
    component commitmentBits = Num2Bits(248);
    
    nullifierInputBits.in <== secret;
    commitmentBits.in <== commitment;
    
    for (var i = 0; i < 248; i++) {
        nullifierHasher.in[i] <== nullifierInputBits.out[i];
        nullifierHasher.in[i + 248] <== commitmentBits.out[i];
    }
    
    nullifier <== nullifierHasher.out[0];

    signal collegeIdSquare;
    collegeIdSquare <== collegeId * collegeId;
}

component main {public [root, collegeId, studentIdHash]} = StudentVerifier(20);