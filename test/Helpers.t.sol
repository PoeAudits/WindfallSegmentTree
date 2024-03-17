//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "lib/forge-std/src/Test.sol";
import {WindfallSegmentTree, WindfallState} from "src/WindfallSegmentTree.sol";
import {ISegmentTree} from "src/Interfaces/Interfaces.sol";
contract Helpers is Test{

    string private checkpointLabel;
    uint256 private checkpointGasLeft = 1; // Start the slot warm.

        /*//////////////////////////////////////////////////////////////
                             Gas Functions
    //////////////////////////////////////////////////////////////*/

    function startMeasuringGas(string memory label) internal virtual {
        checkpointLabel = label;

        checkpointGasLeft = gasleft();
    }

    function stopMeasuringGas() internal virtual {
        uint256 checkpointGasLeft2 = gasleft();

        // Subtract 100 to account for the warm SLOAD in startMeasuringGas.
        uint256 gasDelta = checkpointGasLeft - checkpointGasLeft2 - 100;

        emit log_named_uint(string(abi.encodePacked(checkpointLabel, " Gas")), gasDelta);
    }
    /*//////////////////////////////////////////////////////////////
                             Tree Display
    //////////////////////////////////////////////////////////////*/
    function printTree(address segmentTree) internal {
            WindfallState.Node[] memory nodes; 
            bytes16[] memory currentNode;
            bytes16[][] memory nodeChildren;
            uint128[][] memory nftChildren;
            (bool ok, bytes memory data) =  segmentTree.call(abi.encodeWithSignature("GetTree()"));
            assert(ok);
            (nodes, currentNode, nodeChildren, nftChildren) = abi.decode(data, (WindfallState.Node[], bytes16[], bytes16[][], uint128[][]));

            uint256 counter = nodes.length;
            bytes16[] memory _nodeChildren;
            uint128[] memory _nftChildren;
            for (uint256 i; i < counter; ++i) {
                _nodeChildren = nodeChildren[i];
                _nftChildren = nftChildren[i];
                printNode(nodes[i], currentNode[i], i);
                printBytes16Array(_nodeChildren, i);
                printUint128Array(_nftChildren, i);
            }
    }


    function printNode(WindfallState.Node memory _node, bytes32 currentNode, uint256 _index) internal view {
        console.log("Node: ", _index);
        console.log("Node Id: ", currentNode);
        console.log("{");
        string memory sumString = string(abi.encodePacked("Sum: ", vm.toString(_node.sum)));
        string memory parentString = string(abi.encodePacked("Parent: ", vm.toString(_node.parentNode)));
        console2.logString(sumString);
        console2.logString(parentString);
        console.log("}");
    }

    function printBytes16Array(bytes16[] memory _arr, uint256 _index) internal {
        console.log("nodeChildren of Node ", _index);
        console.log("[");
        for (uint256 i; i < _arr.length; ++i) {
            string memory entree =  string(abi.encodePacked(vm.toString(_arr[i])));
            console2.logString(entree);
        }
        console.log("]");
    }

    function printUint128Array(uint128[] memory _arr, uint256 _index) internal {
        console.log("nftChildren of Node ", _index);
        console.log("[");
        for (uint256 i; i < _arr.length; ++i) {
            string memory entree =  string(abi.encodePacked(vm.toString(_arr[i])));
            console2.logString(entree);
        }
        console.log("]");
    }

}