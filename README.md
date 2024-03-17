Haven't written the proper documentation for this yet. Ill provide better documentation if we decide to do the gas audit. 

The file I need optimized is src/WindfallSegmentTree.sol.

The functions are mostly internal so I also provided a simple harness.

The test function is fairly barebones, most of my tests are for the whole system and can't be seperated out easily. The helpers test includes gas testing functions from solmate, and a method to visualize the tree structure a little better. 

The basic idea is to construct a data structure that will allow the protocol to determine a winner chosen randomly on chain. The naive approach is put all the users in an array or mapping with how many entrees they have, and iterate through it to determine who won based on a random number between 0 and the maximum number of entrees. You would sum up each person's entrees and when it became greater than the random number, that person would win. This doesn't work well in solidity due to gas constraints. The process exceedes the block-gas limit after a few thousands users, not to mention the gas cost alone becomes a burden to the protocol. 

Instead, we could use a tree data structure, and this implementation is based on a segment tree. Each node in the segment tree aggregates the values of all the nodes below it, so we can significantly reduce the computation of winning users. This does offload some of the gas cost to users when they first enter the system, as an addition to the tree will likely require updating the storage of multiple nodes. The "taller" the tree the more gas will be required for the users to enter the system, whereas the wider the tree the more gas will be required to search through the system. The current example is set to have a maximum of 2 children per node (for both nfts and nodes, more on that later), however I expect to launch it with around 10 children per node. My own, somewhat limited, gas testing made it seem the best range for the number of children was between 8 and 16, and I chose 10 due to the difference in cost of SLOAD vs SSTORE opcodes. 

Below is the output of the included test, and I will do my best to explain it:

First thing to note is that there are 7 users entered into the tree. Each user is represented by an NFT which contains two fields, the value of the nft and the nodeParent, which is which node is responsible for this nft. I used uint128 and bytes16 variables in the struct to try and pack the data into one storage slot. A uint128 should be sufficient to store the total value of all the tokens in the system, since its greater than the total supply of the chain I'm deploying this to. Similarly, each node has two values, the sum of everything it "contains", and its parentNode. There are two special nodes: ROOT and NULL. The root is created during deployment in __SegmentTree_init_unchained(), and NULL doesn't technically exist. NULL is the bytes representation of the parent of the ROOT. This is effectively my stopping condition when iterating through the tree, since having the parent node of the ROOT be zero would most likely cause problems. 

Looking at the below logs, Node 0 is the ROOT, and its Sum value is the total amount of entrees in the system. It can be found in the nodes mapping at bytes16 value: 0x043be0b0c1ac1239ef2943cb7fae6c7300000000000000000000000000000000. Its parent is the NULL value which is 0xbb4e1f8434f661d4c52cce6e51dba6eb00000000000000000000000000000000. The root node contains two node children and two nft children, since the MAX_CHILDREN is set to two at the moment. It's node children are Node 1 and Node 2, and you can see in Node 1 and 2 that both of their parents are Node 0. At first glance, it seems a bit off since the Sum of Node 1 and Node 2 aren't equal to the sum of Node zero, but that is due to Node 0 having its own children, NFT 0 and 1. The reason there are both Nfts and Nodes, and that each node has children of both is due to having to create the tree from the top down rather than from the bottom up. Most segment trees are built from the bottom up on an existing array, but that doesn't work here. 

Another thing to note when searching through the tree is that new entrees are considered the low values in the tree. So a call to _searchTree with the same value input may result in different winners if more users are added between the calls. 

Ran 2 tests for test/WindfallSegementTree.t.sol:SegmentTreeTest
[PASS] testAddingToTree() (gas: 755941)
Logs:
  Node:  0
  0x043be0b0c1ac1239ef2943cb7fae6c7300000000000000000000000000000000
  {
  Sum: 29460000000000000000
  Parent: 0xbb4e1f8434f661d4c52cce6e51dba6eb00000000000000000000000000000000
  }
  nodeChildren of Node  0
  [
  0xb10e2d527612073b26eecdfd717e6a3200000000000000000000000000000000
  0x405787fa12a823e0f2b7631cc41b3ba800000000000000000000000000000000
  ]
  nftChildren of Node  0
  [
  0
  1
  ]
  Node:  1
  0xb10e2d527612073b26eecdfd717e6a3200000000000000000000000000000000
  {
  Sum: 15030000000000000000
  Parent: 0x043be0b0c1ac1239ef2943cb7fae6c7300000000000000000000000000000000
  }
  nodeChildren of Node  1
  [
  0xc2575a0e9e593c00f959f8c92f12db2800000000000000000000000000000000
  ]
  nftChildren of Node  1
  [
  2
  3
  ]
  Node:  2
  0x405787fa12a823e0f2b7631cc41b3ba800000000000000000000000000000000
  {
  Sum: 11080000000000000000
  Parent: 0x043be0b0c1ac1239ef2943cb7fae6c7300000000000000000000000000000000
  }
  nodeChildren of Node  2
  [
  ]
  nftChildren of Node  2
  [
  4
  5
  ]
  Node:  3
  0xc2575a0e9e593c00f959f8c92f12db2800000000000000000000000000000000
  {
  Sum: 7030000000000000000
  Parent: 0xb10e2d527612073b26eecdfd717e6a3200000000000000000000000000000000
  }
  nodeChildren of Node  3
  [
  ]
  nftChildren of Node  3
  [
  6
  ]




## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
