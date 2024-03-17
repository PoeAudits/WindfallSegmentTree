//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/forge-std/src/Test.sol";
import "src/Harness/SegmentTreeHarness.sol";
import {WindfallState} from "src/WindfallState.sol";

import {Helpers} from "test/Helpers.t.sol";

contract SegmentTreeTest is Test, Helpers {

    SegmentTreeHarness public segmentTree;
    address public _segmentTree;

    function setUp() public {
        segmentTree = new SegmentTreeHarness();
        _segmentTree = address(segmentTree);
    }

    function testInit() public {
        assertEq(segmentTree.GetNextNodeId(), 1);
    }

    function testAddingToTree() public {
        (, uint128 tokenOne) = segmentTree.CreateUser(1.15e18);
        (, uint128 tokenTwo) = segmentTree.CreateUser(2.2e18);
        (, uint128 tokenThree) = segmentTree.CreateUser(3.3e18);
        (, uint128 tokenFour) = segmentTree.CreateUser(4.7e18);

        segmentTree.UpdateTreeAddUser(tokenOne);
        segmentTree.UpdateTreeAddUser(tokenTwo);
        segmentTree.UpdateTreeAddUser(tokenThree);
        segmentTree.UpdateTreeAddUser(tokenFour);

        Helpers.printTree(_segmentTree);

    }







}