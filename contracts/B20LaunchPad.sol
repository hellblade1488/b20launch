// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Minimal subset of the B20 Factory precompile interface.
///         Full interface: https://github.com/base/base-std
interface IB20Factory {
    function createB20(uint8 variant, bytes32 salt, bytes calldata params, bytes[] calldata initCalls)
        external
        payable
        returns (address token);

    function getB20Address(uint8 variant, address sender, bytes32 salt) external view returns (address);
}

/// @title  B20LaunchPad
/// @author hellblade1488
/// @notice Thin pass-through to the canonical B20 Factory precompile, used by
///         https://b20launch.com. Exists so every launch emits an indexable
///         `TokenLaunched` event and (optionally, later) collects a flat fee.
///
///         Trust model: the launchpad holds NO roles and NO access to created
///         tokens. Token admin is whoever the user sets as `initialAdmin`
///         inside `params` — the factory grants it directly.
///
///         The user-provided salt is mixed with the caller address, so no user
///         can occupy or front-run another user's token address.
contract B20LaunchPad {
    /// @notice Canonical B20 Factory precompile (same address on every Base network).
    IB20Factory public constant FACTORY = IB20Factory(0xB20f000000000000000000000000000000000000);

    /// @notice Contract owner (fee admin and fee recipient).
    address public owner;

    /// @notice Flat launch fee in wei. Zero at deployment; may change via `setFee`.
    uint256 public fee;

    event TokenLaunched(address indexed creator, address indexed token, uint8 indexed variant, bytes32 salt);
    event FeeUpdated(uint256 newFee);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    error NotOwner();
    error WrongFee(uint256 sent, uint256 required);
    error WithdrawFailed();
    error ZeroAddress();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /// @notice Creates a B20 token via the factory precompile.
    ///
    /// @dev The factory rejects attached ETH, so the fee stays on this contract.
    ///      Exact-fee check (not `>=`) protects users from overpaying.
    ///
    /// @param variant   0 = ASSET, 1 = STABLECOIN.
    /// @param salt      User salt; mixed with `msg.sender` before hitting the factory.
    /// @param params    ABI-encoded variant create-params struct (leading version byte = 1).
    /// @param initCalls Bootstrap calls executed on the new token by the factory.
    ///
    /// @return token Address of the created token.
    function launch(uint8 variant, bytes32 salt, bytes calldata params, bytes[] calldata initCalls)
        external
        payable
        returns (address token)
    {
        if (msg.value != fee) revert WrongFee(msg.value, fee);
        token = FACTORY.createB20(variant, _finalSalt(msg.sender, salt), params, initCalls);
        emit TokenLaunched(msg.sender, token, variant, salt);
    }

    /// @notice Predicts the token address `launch` would produce for (`creator`, `salt`).
    function predictAddress(uint8 variant, address creator, bytes32 salt) external view returns (address) {
        return FACTORY.getB20Address(variant, address(this), _finalSalt(creator, salt));
    }

    function setFee(uint256 newFee) external onlyOwner {
        fee = newFee;
        emit FeeUpdated(newFee);
    }

    function withdraw() external onlyOwner {
        (bool ok,) = owner.call{value: address(this).balance}("");
        if (!ok) revert WithdrawFailed();
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function _finalSalt(address creator, bytes32 salt) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(creator, salt));
    }
}
