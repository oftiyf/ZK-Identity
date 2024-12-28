// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.11;

import "./hash_MiMCp.sol";
import "./merkle_tree.sol";
import "./pure_verifier.sol";


contract mianverfier is MerkleTree, Groth16Verifier {
    
    event passed(address indexed recipient, bytes32 nullifierHash, bytes32 newCommitment, uint256 blockNumber);
    mapping(address => bool) public passed_address;
    mapping(address => uint256) public passed_block;
    mapping(bytes32 => bool) public nullifierHashes;
    mapping(address => bool) public admins;

    modifier onlyAdmin() {
        require(admins[msg.sender], "Only admin can perform this action");
        _;
    }

    constructor() public {
        admins[msg.sender] = true; // 部署合约的地址设为初始管理员
    }

    function prover(
        uint256[8] memory _proof,    // 零知识证明
        bytes32 _root,               // merkle树根
        bytes32 _nullifierHash,      // 用于防止双重支付的 nullifier
        uint256 _collegeId,         // 学院ID
        bytes32 _newCommitment,      // 新的承诺值（新的叶子节点）
        address payable prover   // 证明者地址
    ) external returns (uint256) {
        // 验证零知识证明
        //root nullifierHash collegeId newcommitment
        require(
            verifyProof(
                _proof,
                [
                    uint256(_root),
                    uint256(_nullifierHash),
                    uint256(_collegeId),
                    uint256(_newCommitment)
                ]
            ),
            "Invalid proof"
        );
        
        // 验证merkle树根
        require(getRoot() == uint256(_root), "Invalid root");
        
        // 验证nullifier是否已使用，后面这个是newcommitment检查忽略哈希碰撞
        require(!nullifierHashes[_nullifierHash], "The note has been already spent");
        require(!nullifierHashes[_newCommitment], "Used nullifierhashers");
        
        // 标记 nullifier 为已使用
        nullifierHashes[_nullifierHash] = true;
        
        // 插入新的承诺到 Merkle 树
        uint256 insertedIndex = insert(uint256(_newCommitment));
        
        // 触发事件
        emit passed(prover, _nullifierHash, _newCommitment, block.number);
        passed_address[prover] = true;
        passed_block[prover] = block.number;

        return insertedIndex;
    }

    function check_passed(address _address) public view returns (bool) {
        return passed_address[_address] && passed_block[_address] >= block.number - 20;
    }

    function adminInsertLeaf(uint256 _leaf) external onlyAdmin {
        require(!isKnownLeaf[_leaf], "Leaf already exists");
        insert(_leaf);
    }

    function addAdmin(address _newAdmin) external onlyAdmin {
        require(!admins[_newAdmin], "Address is already an admin");
        admins[_newAdmin] = true;
    }

    function removeAdmin(address _admin) external onlyAdmin {
        require(admins[_admin], "Address is not an admin");
        require(_admin != msg.sender, "Admin cannot remove themselves");
        admins[_admin] = false;
    }

    function() external payable {}
}
