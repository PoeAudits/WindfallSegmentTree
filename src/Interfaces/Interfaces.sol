interface ISegmentTree {
        // Tree Data Structures
    struct Node {
        uint128 sum;
        bytes16 parentNode;
    }
    function getNodeId(uint128 nodeCounter) external pure returns(bytes16);
    function GetTree() external view returns(Node[] memory, bytes16[] memory, bytes16[][] memory, uint128[][] memory);
}