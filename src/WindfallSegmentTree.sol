//SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {WindfallState} from "src/WindfallState.sol";
import {SafeCast} from "lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol";
import {Initializable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";

contract WindfallSegmentTree is WindfallState, Initializable {
    using SafeCast for uint256;

    error IsZero();
    error SearchFailed(uint128 failValue);

    // 0x043be0b0c1ac1239ef2943cb7fae6c733c371759b453c4bd3c67b6c80ea3be00
    // 0x043be0b0c1ac1239ef2943cb7fae6c7300000000000000000000000000000000
    bytes16 public constant ROOT = bytes16(keccak256(bytes("ROOT"))); 
    // 0xbb4e1f8434f661d4c52cce6e51dba6eb9c909f0b452eb22968b55416ecb18fb5
    // 0xbb4e1f8434f661d4c52cce6e51dba6eb00000000000000000000000000000000
    bytes16 public constant NULL = bytes16(keccak256(bytes("NULL")));

    function __SegmentTree_init() internal onlyInitializing {
        __SegmentTree_init_unchained();
    }

    function __SegmentTree_init_unchained() internal onlyInitializing {
        Node memory root = Node({ sum: 0, parentNode: NULL });
        nodeIndex[nextNodeId] = ROOT;
        nextNodeId++;
        nodes[ROOT] = root;
    }

    /// @notice Function to calculate the next node in the sequence
    /// @dev Encoding must include a counter variable, but can be extended if needed
    /// @dev This is effectively the nodeIndex variable mapping
    /// @return The bytes16 representation of the node
    function getNodeId(uint128 nodeCounter) public pure virtual returns(bytes16) {
        return bytes16(keccak256(abi.encode(nodeCounter)));
    }

    /// @notice Function to add a node to the tree
    /// @dev Called when other nodes are full
    function _updateTreeAddNode() private {
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


    /// @notice Add an nft to the tree to be chosen
    /// @dev Could be called when minting tokens, or due to other conditions
    /// @param nftId The id of the NFT to add to the tree 
    function _updateTreeAddUser(uint128 nftId) internal virtual {
        // If tree is full, add node to tree
        if (nextNftParent >= nextNodeId) {
            _updateTreeAddNode(); 
        }

        // Cache value to pass into updateNodeSumValues Later
        bytes16 nftParentNode = nodeIndex[nextNftParent];
        uint128[] storage children = nftChildren[nftParentNode];
        // Add nft to the nftChildrenArray
        children.push(nftId);

        User storage user = users[nftId];
        user.nodeParent = nftParentNode;
        // Parent node cached already
        if (children.length >= MAX_CHILDREN) {
            nextNftParent++;
        }

        // Update sum values of nodes
        _updateTreeIncrementNodes(nftId, user.value);

    }

    /// @notice Function to increase existing nft value data
    /// @dev Input validation must be done before calling
    /// @param nftId The nft to increase the value
    /// @param amount The amout to increase the value
    function _updateTreeAddValue(uint128 nftId, uint128 amount) internal virtual {
        users[nftId].value += amount;
        _updateTreeIncrementNodes(nftId, amount);
    }

    /// @notice Function to decrease existing nft value data
    /// @dev Input validation must be done before calling
    /// @dev If token is being burned, call _updateTreeUserRemove instead
    /// @param nftId The nft to decrease the value
    /// @param amount The amout to decrease the value
    function _updateTreeSubtractValue(uint128 nftId, uint128 amount) internal virtual {
        users[nftId].value -= amount;
        _updateTreeDecrementNodes(nftId, amount);
    }

    /// @notice Increment nodes in tree the value of the nft
    /// @dev Called when adding an nft to the stake pool
    /// @param nftId The id of the NFT to add
    function _updateTreeIncrementNodes(uint128 nftId, uint128 amount) internal {
        bytes16 nodeParent = users[nftId].nodeParent;
        require(nodeParent != bytes16(0), "Error Adding To Tree");
        Node memory currentNode;
        while (nodeParent != NULL) {
            currentNode = nodes[nodeParent];
            nodes[nodeParent].sum += amount;
            nodeParent = currentNode.parentNode;
        } 
    }

    /// @notice Decrement nodes in tree the value of the nft
    /// @dev Called when removing an nft from the stake pool during unstaking
    /// @dev Does not delete the nft data
    /// @dev Relies on an intact entreeTokens value from the nft
    /// @param nftId The id of the NFT to remove
    function _updateTreeDecrementNodes(uint128 nftId, uint128 amount) internal {
        bytes16 nodeParent = users[nftId].nodeParent;
        require(nodeParent != bytes16(0), "Error Removing To Tree");
        Node memory currentNode;
        while (nodeParent != NULL) {
            currentNode = nodes[nodeParent];
            nodes[nodeParent].sum -= amount;
            nodeParent = currentNode.parentNode;
        } 
    }


    /// @notice Search the tree for an NFT corresponding to value
    /// @param value The search parameter, between 0 and the sum of the root node
    /// @return The nft the value corresponds to
    function _searchTree(uint128 value) internal virtual returns(uint128) {
        Node memory root = nodes[ROOT];
        // The sum variable of the root is the total sum of the tree
        uint128 totalValue = root.sum;
        require(value <= totalValue, "Invalid Value");
        bytes16 parent = ROOT;

        bytes16 target;
        uint128 cumValue;


        while (nodeChildren[parent].length > 0) {
            // Loop over the node children to find which branch value lies in
            (target, cumValue) = _loopNodeChildren(parent, cumValue, value); 

            // Case for when sum of all node children < value
            // This happens when the target value is in the parent itself
            // Loop over nodes first since they should have higher value
            if (target == parent) {
                return _loopNftChildren(parent, cumValue, value);
            }
            parent = target;
        }

        // nodeChildren[parent].length == 0
        // We have found the node that contains the winner
        // Loop over the children of the node to find the winner
        return _loopNftChildren(parent, cumValue, value);

    }

    function _loopNodeChildren(bytes16 parentNode, uint128 cumValue, uint128 targetValue) internal view returns(bytes16, uint128) {
        bytes16[] memory children = nodeChildren[parentNode];
        for (uint128 i; i < children.length; ++i) {
            bytes16 child = children[i];
            cumValue += nodes[child].sum;
            if (cumValue >= targetValue) {
                // Exceeded value, need value before the add op
                return (child, cumValue - nodes[child].sum);
            }
        }
        // Loop ended and we didn't find it, so it must be in the NFT children of the parent
        return (parentNode, cumValue);
    }


    function _loopNftChildren(bytes16 parent, uint128 cumValue, uint128 targetValue) internal view returns(uint128 nftId) {
        uint128[] memory nftChildrenArr = nftChildren[parent];
        uint256 len = nftChildrenArr.length;

        for (uint128 i; i < len; ++i) {
            cumValue += users[nftChildrenArr[i]].value;
            if (cumValue >= targetValue) {
                return nftChildrenArr[i];
            }
        }
        // If we can't find a value above, something failed critically
        revert SearchFailed(targetValue);
    }


    /// @notice Function to create a new User
    /// @dev Stores the user in users mapping and updates numberOfUsers
    /// @param amount The amount of entrees the new user has
    function _createUser(uint128 amount) internal virtual returns(User memory newUser) {
        if (amount == 0) revert IsZero();

        newUser = User({
            value: amount,
            nodeParent: bytes16(0)
        });

        users[numberOfUsers] = newUser;
        numberOfUsers++;
    }

    function getUserById(uint256 id) public view returns (User memory) {
        return users[id];
    }

    // Function added for testing
    // Allows tests to display the tree information
    function GetTree() external view returns(Node[] memory, bytes16[] memory, bytes16[][] memory, uint128[][] memory) {
        Node[] memory tree = new Node[](nextNodeId);
        bytes16[] memory currentNode = new bytes16[](nextNodeId);
        bytes16[][] memory nodeChilds = new bytes16[][](nextNodeId); 
        uint128[][] memory childs = new uint128[][](nextNodeId);
        for (uint64 i; i < nextNodeId; ++i) {
            bytes16 current = nodeIndex[i];
            tree[i] = nodes[current];
            currentNode[i] = current;
            nodeChilds[i] = nodeChildren[current]; 
            childs[i] = nftChildren[current]; 
        }
        return (tree, currentNode, nodeChilds, childs); 
    }


}