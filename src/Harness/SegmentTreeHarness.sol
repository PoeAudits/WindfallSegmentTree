//SPDX-LICENSE-IDENTIFIER: MIT
pragma solidity 0.8.24;

import {WindfallSegmentTree} from "src/WindfallSegmentTree.sol";

contract SegmentTreeHarness is WindfallSegmentTree {

    constructor() {
        initialize();
    }

    function initialize() public initializer {
        __SegmentTree_init();
    }



/*
    function getNodeId(uint128 nodeCounter) public pure virtual returns(bytes16) {
    function _updateTreeAddNode() private {
    function _updateTreeAddUser(uint128 nftId) internal virtual {
    function _updateTreeAddValue(uint128 nftId, uint128 amount) internal virtual {
    function _updateTreeSubtractValue(uint128 nftId, uint128 amount) internal virtual {
    function _updateTreeIncrementNodes(uint128 nftId, uint128 amount) internal {
    function _updateTreeDecrementNodes(uint128 nftId, uint128 amount) internal {
    function _searchTree(uint128 value) internal virtual returns(uint128) {
    function _loopNodeChildren(bytes16 parentNode, uint128 cumValue, uint128 targetValue) internal view returns(bytes16, uint128) {
    function _loopNftChildren(bytes16 parent, uint128 cumValue, uint128 targetValue) internal view returns(uint128 nftId) {
    function _createUser(uint128 amount) internal virtual returns(User memory newUser) {
    function getUserById(uint256 id) public view returns (User memory) {
    function GetTree() external view returns(Node[] memory, bytes16[] memory, bytes16[][] memory, uint128[][] memory) {

*/

    function UpdateTreeAddNode() external {
                // Get the next available parent
        bytes16 parent = nodeIndex[nextNodeParent]; 
        // Create the node object
        Node memory newNode = Node({sum: 0, parentNode: parent}); 
        // Cache the id of the newly generated node
        bytes16 nodeId = getNodeId(nextNodeId);
        // Add the node to the index of nodes
        // Maybe add some checking?
        nodeIndex[nextNodeId] = nodeId;
        // Increment the node index counter
        nextNodeId++;
        // Store the node itself
        nodes[nodeId] = newNode;
        // Add the new node to the child of the parent
        nodeChildren[parent].push(nodeId);
        // Check if node is full, if full, increment parent counter
        if (nodeChildren[parent].length >= MAX_CHILDREN) {
            nextNodeParent++;
        }
    }


    function UpdateTreeAddNodeReturn() external returns(uint128, uint128) {
                // Get the next available parent
        bytes16 parent = nodeIndex[nextNodeParent]; 
        // Create the node object
        Node memory newNode = Node({sum: 0, parentNode: parent}); 
        // Cache the id of the newly generated node
        bytes16 nodeId = getNodeId(nextNodeId);
        // Add the node to the index of nodes
        // Maybe add some checking?
        nodeIndex[nextNodeId] = nodeId;
        // Increment the node index counter
        nextNodeId++;
        // Store the node itself
        nodes[nodeId] = newNode;
        // Add the new node to the child of the parent
        nodeChildren[parent].push(nodeId);
        // Check if node is full, if full, increment parent counter
        if (nodeChildren[parent].length >= MAX_CHILDREN) {
            nextNodeParent++;
        }

        return (nextNodeId, nextNodeParent);
    }


    function UpdateTreeAddUser(uint128 nftId) external {
        _updateTreeAddUser(nftId);
    }

    function UpdateTreeAddValue(uint128 nftId, uint128 amount) external {
        _updateTreeAddValue(nftId, amount);
    }

    function UpdateTreeSubtractValue(uint128 nftId, uint128 amount) external {
        _updateTreeSubtractValue(nftId, amount);
    }

    function SearchTree(uint128 value) external returns (uint128) {
        return _searchTree(value);
    }

    function LoopNodeChildren(bytes16 parentNode, uint128 cumValue, uint128 targetValue) external view returns(bytes16, uint128) {
        return _loopNodeChildren(parentNode, cumValue, targetValue);
    }

    function LoopNftChildren(bytes16 parent, uint128 cumValue, uint128 targetValue) internal view returns(uint128 nftId) {
        return _loopNftChildren(parent, cumValue, targetValue);
    }

    function CreateUser(uint128 amount) external returns (User memory newUser, uint128) {
        return (_createUser(amount), numberOfUsers - 1);
    }

    function GetNodeIndex(uint128 i) external view returns(bytes16){
        return nodeIndex[i];
    }

    function GetNodes(bytes16 i) external view returns(Node memory){
        return nodes[i];
    }
    
    function GetNodeChildren(bytes16 i) external view returns(bytes16[] memory){
        return nodeChildren[i];
    }
    function GetNftChildren(bytes16 i) external view returns(uint128[] memory){
        return nftChildren[i];
    }

    function GetUser(uint128 i) external view returns(User memory){
        return users[i];
    }

    function GetNextNodeParent() external view returns(uint128) {
        return nextNodeParent;
    }
    function GetNextNftParent() external view returns(uint128) {
        return nextNftParent;
    }
    function GetNextNodeId() external view returns(uint128) {
        return nextNodeId;
    }
}