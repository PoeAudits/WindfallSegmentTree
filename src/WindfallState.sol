// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract WindfallState {

    event debug(string s, uint256 n);

    // Tree Data Structures
    struct Node {
        uint128 sum;
        bytes16 parentNode;
    }

    // Holds data for each NFT
    struct User {
        uint128 value;
        bytes16 nodeParent;
    }

    address internal admin;
    
    // Sets the max number of children for nodes and Nfts
    // Set to 10?
    // Set to 2 for testing
    uint8 internal constant MAX_CHILDREN = 2;

    IERC20 public asset;

    // Tracks node index to bytes16
    mapping(uint128 => bytes16) internal nodeIndex;
    // Tracks nodes from their bytes representation
    mapping(bytes16 => Node) internal nodes;

    // Tracks the node children of each node
    mapping(bytes16 => bytes16[]) internal nodeChildren;
    // Tracks the nft children of each node
    mapping(bytes16 => uint128[]) internal nftChildren;

    // Map integers to the user struct for iteration.
    mapping(uint256 => User) internal users;
    // Map integers to the user struct for iteration.

    // Counters
    uint128 public numberOfUsers;
    uint128 internal nextNodeParent;
    uint128 internal nextNodeId;
    uint128 internal nextNftParent;

    /*//////////////////////////////////////////////////////////////
                               APPEND ONLY
    //////////////////////////////////////////////////////////////*/



}