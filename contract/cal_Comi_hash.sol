// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.11;

import "./hash_MiMCp.sol";

contract calculate {
    function calCommitment(uint256 secret, uint256 studentId, uint256 nullifier) public pure returns (uint256) {
        // First calculate hash(secret, studentId)
        uint256[] memory input1 = new uint256[](2);
        input1[0] = secret;
        input1[1] = studentId;
        uint256 firstHash = MiMC.Hash(input1, 0);
        
        // Then calculate hash(firstHash, nullifier)
        uint256[] memory input2 = new uint256[](2);
        input2[0] = firstHash;
        input2[1] = nullifier;
        return MiMC.Hash(input2, 0);
    }
}

