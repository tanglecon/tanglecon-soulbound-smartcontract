// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

error FunctionNotSupported();


contract TestContract is ERC1155, Ownable {
    using Strings for uint256;

    mapping(uint256 => string) testMapURI;
    mapping(uint256 => uint256) testMap;

    string private ending;
    
    constructor(string memory _suffix) ERC1155("") {
        ending = _suffix;
    }


    function testdrop(uint256 id, address holder) external onlyOwner {
        _mint(holder, id, 1, "");
    }

    function testburnA(address holder, uint256 id) external onlyOwner {
        _burn(holder, id, 1);
    }

    function testSuf(string calldata _suffix) external onlyOwner {
        ending = _suffix;
    }

    function testSetURI(uint256 var1, string calldata var2) external onlyOwner {
        testMapURI[var1] = var2;
    }

    function testMapEd(uint256 var1, uint256 var2, uint256 var3) external onlyOwner {
        for (uint i = 0; i < var2; i++){
            testMap[var1 + i] = var3;
        }
    }

    function testBurn(uint256 id) external {
        _burn(msg.sender, id, 1);
    }

    function uri(uint256 id) public view override returns (string memory) {
        string memory editionBaseURI = testMapURI[testMap[id]];
        return string(abi.encodePacked(editionBaseURI, id.toString(), ending));
    }
    
    
    function setApprovalForAll(
        address,
        bool
    ) public pure override {
        revert FunctionNotSupported();
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public pure override {
        revert FunctionNotSupported();
    }

    function safeBatchTransferFrom(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public pure override {
        revert FunctionNotSupported();
    }
}