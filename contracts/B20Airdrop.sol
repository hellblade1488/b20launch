// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @title  B20Airdrop
/// @author hellblade1488
/// @notice Stateless batch distributor used by https://b20launch.com.
///         Sends `amounts[i]` of `token` from the caller to each `recipients[i]`
///         in one transaction. Requires a prior ERC-20 `approve` for the total.
///
///         Trust model: no owner, no fees, no storage. The contract can only move
///         tokens the caller explicitly approved, and only within the calling tx.
contract B20Airdrop {
    error LengthMismatch();
    error EmptyBatch();
    error TransferFailed(uint256 index);

    event Airdropped(address indexed sender, address indexed token, uint256 recipients, uint256 total);

    function disperse(address token, address[] calldata recipients, uint256[] calldata amounts) external {
        if (recipients.length != amounts.length) revert LengthMismatch();
        if (recipients.length == 0) revert EmptyBatch();
        uint256 total;
        for (uint256 i = 0; i < recipients.length; i++) {
            if (!IERC20(token).transferFrom(msg.sender, recipients[i], amounts[i])) revert TransferFailed(i);
            total += amounts[i];
        }
        emit Airdropped(msg.sender, token, recipients.length, total);
    }
}
