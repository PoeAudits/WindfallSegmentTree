// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {
    ITurnstile,
    IWindfallToken,
    IVCNote,
    ILendingLedger
    } from "src/Interfaces/Interfaces.sol";


import {UnstakeQueue} from "src/Utils/UnstakeQueue.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


    // Only used for deployment
struct InitData {
    // Windfall Init
    address ADMIN;
    address ASSET;
    address LENDINGLEDGER;
    // State Time Init
    uint64 UNSTAKETIME;
    uint64 NEXTDRAWTIMESTAMP;
    // State Stake Init
    uint32 FEEPERCENT;
    uint32 REWARDSDIVISOR;
    uint32 SUPERMULTIPLIER;
    uint32 SUPERREWARDSFREQUENCY;
    uint64 MINSTAKE;
    uint64 DRAWCOUNTER;
    // Misc
    uint48 INITIALDELAY;
    address TURNSTILE;
    uint256 TURNSTILETOKEN;
}


contract WindfallState {


    event debug(string s, uint256 n);

    // Storage Data Structures 
    struct AdminTimeVariables {
        uint64 unstakeTime;
        uint64 nextDrawTimestamp;
    }

    struct AdminStakeVariables {
        uint32 feePercent;
        uint32 rewardsDivisor;
        uint32 superMultiplier;
        uint32 superRewardsFrequency;
        uint64 minStake;
        uint64 drawCounter;
    }

    struct Rewards {
        uint128 rewardsToDistribute;
        uint128 dayReward;
    }

    // Variables used for front end past winners.
    struct Winner {
        uint128 winningToken;
        uint128 winningAmount;
    }

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


    AdminTimeVariables public timeVariables;
    AdminStakeVariables public stakeVariables;
    Rewards internal windfallRewards;

    address internal admin;
    address internal treasury;
    address internal lendingLedgerMarket; 

    uint8 internal constant MAX_CHILDREN = 2;

    IWindfallToken internal windfallToken; 
    IVCNote internal vcNOTE;
    ILendingLedger internal lendingLedger;

    IERC20 public asset;

    mapping(uint256 => Winner) internal winners; // Store data of past winners for front end

    // Keep track of claimable rewards for the winning tokens
    mapping(uint256 => uint256) internal winnerRewards;

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
    //Non-Array solution
    mapping(address => UnstakeQueue.UserUnstakeQueue) internal usersUnstake;

    // Counters
    uint128 public numberOfUsers;
    uint128 internal nextNodeParent;
    uint128 internal nextNodeId;
    uint128 internal nextNftParent;



    /*//////////////////////////////////////////////////////////////
                            Access Roles
    //////////////////////////////////////////////////////////////*/


    /*//////////////////////////////////////////////////////////////
                               APPEND ONLY
    //////////////////////////////////////////////////////////////*/



}