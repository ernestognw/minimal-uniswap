// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Uniswap V1 Exchange ETH-to-token functions interface
/// @author Ernesto García (@ernestognw)
/// @notice Only Exchange's ETH-to-token functions
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
interface IETHToToken {
    /// @notice Convert ETH to tokens.
    /// @dev User specifies exact input (msg.value) and minimum output.
    /// @param minTokens Minimum tokens bought.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @return tokensBought Amount of tokens bought.
    function ethToTokenSwapInput(uint256 minTokens, uint64 deadline) external payable returns (uint256 tokensBought);

    /// @notice Convert ETH to tokens.
    /// @dev User specifies maximum input (msg.value) and exact output.
    /// @param tokensBought Amount of tokens bought.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @return ethSold Amount of ETH sold.
    function ethToTokenSwapOutput(uint256 tokensBought, uint64 deadline) external payable returns (uint256 ethSold);

    /// @notice Convert ETH to tokens and transfers tokens to recipient.
    /// @dev User specifies exact input (msg.value) and minimum output
    /// @param minTokens Minimum tokens bought.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param recipient The address that receives output tokens.
    /// @return tokensBought Amount of tokens bought.
    function ethToTokenTransferInput(uint256 minTokens, uint64 deadline, address recipient)
        external
        payable
        returns (uint256 tokensBought);

    /// @notice Convert ETH to tokens and transfers tokens to recipient.
    /// @dev User specifies maximum input (msg.value) and exact output.
    /// @param tokensBought Amount of tokens bought.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param recipient The address that receives output tokens.
    /// @return ethSold Amount of ETH sold.
    function ethToTokenTransferOutput(uint256 tokensBought, uint64 deadline, address recipient)
        external
        payable
        returns (uint256 ethSold);

    /// @notice Convert ETH to tokens.
    /// @dev User specifies exact input (msg.value).
    /// @dev User cannot specify minimum output or deadline.
    fallback() external payable;

    /// @notice Convert ETH to tokens.
    /// @dev User specifies exact input (msg.value).
    /// @dev User cannot specify minimum output or deadline.
    receive() external payable;
}
