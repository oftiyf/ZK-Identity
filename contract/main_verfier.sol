// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.11;

import "./hash_MiMCp.sol";
import "./merkle_tree.sol";
import "./pure_verifier.sol";


contract mianverfier{
    //这个映射还要求返回区块数
    event passed(address indexed recipient, bytes32 nullifierHash, bytes32 newCommitment, uint256 blockNumber);
    //写一个映射，地址到bool值的
    mapping(address => bool) public passed_address;
    //写一个映射，地址到区块数的
    mapping(address => uint256) public passed_block;
    function withdraw(
        bytes32 _nullifierHash,      // 用于防止双重支付的 nullifier
        bytes32 _newCommitment,      // 新的承诺值（新的叶子节点）
        uint256[8] memory _proof,    // 零知识证明
        bytes32[] memory _path,      // Merkle路径
        uint32[] memory _positions   // 路径位置
    ) external {
        require(!nullifierHashes[_nullifierHash], "The note has been already spent");
        require(!_newnullifierHashes[_newCommitment], "Used nullifierhashers");
        
        // 标记 nullifier 为已使用
        nullifierHashes[_nullifierHash] = true;
        
        // 插入新的承诺到 Merkle 树
        merkleTree.insert(_newCommitment);
        
        // 触发提款事件
        emit passed(msg.sender, _nullifierHash, _newCommitment, block.number);
        passed_address[msg.sender] = true;
        passed_block[msg.sender] = block.number;
    }
    //写一个函数能够检查指定的地址是否在最近20个区块内通过
    function check_passed(address _address) public view returns (bool) {
        return passed_address[_address] && passed_block[_address] >= block.number - 20;
    }




    // 默认的fallback函数
    function() external payable {}
}
