// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "./hash_MiMCp.sol";

contract MerkleTree {
    uint256[] public tree;
    uint256 public constant LEVELS = 20; 
    uint256 public constant ZERO_VALUE = 0; 
    uint256 public numberOfLeaves = 0;

    // 记录已经插入的叶子节点
    mapping(uint256 => bool) public isKnownLeaf;

    event LeafAdded(uint256 indexed leaf, uint256 indexed leafIndex);
    
    constructor() public {
        // 初始化树，用零值填充
        uint256 size = (1 << (LEVELS + 1)) - 1;
        tree = new uint256[](size);
        
        // 初始化零值
        uint256 current_zero_value = ZERO_VALUE;
        for(uint256 i = 0; i < LEVELS; i++) {
            current_zero_value = hashLeftRight(current_zero_value, current_zero_value);
        }
    }

    // 获取树的根
    function getRoot() public view returns (uint256) {
        return tree[0];
    }

    function hashLeftRight(uint256 left, uint256 right) internal pure returns (uint256) {
        uint256[] memory input = new uint256[](2);
        input[0] = left;
        input[1] = right;
        return MiMC.Hash(input, 0);
    }

    function insert(uint256 leaf) public {
        require(!isKnownLeaf[leaf], "Leaf already exists");
        require(numberOfLeaves < (1 << LEVELS), "Tree is full");

        uint256 currentIndex = numberOfLeaves + (1 << LEVELS) - 1;
        tree[currentIndex] = leaf;
        uint256 currentLevelIndex = currentIndex;
        
        // 更新路径上的所有节点
        for(uint256 i = 0; i < LEVELS; i++) {
            currentLevelIndex = (currentLevelIndex - 1) / 2;
            uint256 left = tree[currentLevelIndex * 2 + 1];
            uint256 right = tree[currentLevelIndex * 2 + 2];
            tree[currentLevelIndex] = hashLeftRight(left, right);
        }

        isKnownLeaf[leaf] = true;
        numberOfLeaves++;
        
        emit LeafAdded(leaf, numberOfLeaves - 1);
    }

    // 获取merkle路径
    function getMerklePath(uint256 leafIndex) public view returns (uint256[] memory, bool[] memory) {
        require(leafIndex < numberOfLeaves, "Leaf index out of bounds");
        
        uint256[] memory path = new uint256[](LEVELS);
        bool[] memory positions = new bool[](LEVELS);
        
        uint256 currentIndex = leafIndex + (1 << LEVELS) - 1;
        
        for(uint256 i = 0; i < LEVELS; i++) {
            uint256 siblingIndex;
            if (currentIndex % 2 == 0) {
                siblingIndex = currentIndex - 1;
                positions[i] = false;
            } else {
                siblingIndex = currentIndex + 1;
                positions[i] = true;
            }
            path[i] = tree[siblingIndex];
            currentIndex = (currentIndex - 1) / 2;
        }
        
        return (path, positions);
    }

    // 验证merkle路径
    function verifyMerklePath(
        uint256 leaf,
        uint256[] memory path,
        bool[] memory positions,
        uint256 root
    ) public pure returns (bool) {
        require(path.length == positions.length, "Path length mismatch");
        
        uint256 computedHash = leaf;
        
        for(uint256 i = 0; i < path.length; i++) {
            if (positions[i]) {
                computedHash = hashLeftRight(computedHash, path[i]);
            } else {
                computedHash = hashLeftRight(path[i], computedHash);
            }
        }
        
        return computedHash == root;
    }
}