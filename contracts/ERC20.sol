// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// OZ helper
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//errors
error ERC20_NotMinter();

contract devUSDC is ERC20, Ownable {
    mapping(address => bool) minters;

    constructor() ERC20("devUSDC", "DUSDC") {}

    modifier onlyMinters() {
        if (!minters[msg.sender]) {
            revert ERC20_NotMinter();
        }
        _;
    }

    function addMinter(address minter) external onlyOwner {
        minters[minter] = true;
    }

    function mint(uint256 amount, address reciever) external onlyMinters {
        _mint(reciever, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 26;
    }
}
