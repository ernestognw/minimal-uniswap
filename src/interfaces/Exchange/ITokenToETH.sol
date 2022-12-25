// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Uniswap V1 Exchange token-to-ETH functions interface
/// @author Ernesto García (@ernestognw)
/// @notice Only Exchange's token-to-ETH functions
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
interface ITokenToETH {
    /// @notice Convert Tokens to ETH.
    /// @dev User specifies exact input and minimum output.
    /// @param tokensSold Amount of Tokens sold.
    /// @param minEth Minimum ETH purchased.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @return ethBought Amount of ETH bought.
    function tokenToEthSwapInput(
        uint256 tokensSold,
        uint256 minEth,
        uint256 deadline
    ) external returns (uint256 ethBought);

    /// @notice Convert tokens to ETH.
    /// @dev User specifies maximum input and exact output.
    /// @param ethBought Amount of ETH purchased.
    /// @param maxTokens Maximum tokens sold.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @return tokensSold Amount of tokens sold.
    function tokenToEthSwapOutput(
        uint256 ethBought,
        uint256 maxTokens,
        uint256 deadline
    ) external returns (uint256 tokensSold);

    /// @notice Convert tokens to ETH and transfers ETH to recipient.
    /// @dev User specifies exact input and minimum output.
    /// @param tokensSold Amount of tokens sold.
    /// @param minEth Minimum ETH purchased.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param recipient The address that receives output ETH.
    /// @return ethBought Amount of ETH bought.
    function tokenToEthTransferInput(
        uint256 tokensSold,
        uint256 minEth,
        uint256 deadline,
        address recipient
    ) external returns (uint256 ethBought);

    /// @notice Convert tokens to ETH and transfers ETH to recipient.
    /// @dev User specifies maximum input and exact output.
    /// @param ethBought Amount of ETH purchased.
    /// @param max_tokens Maximum tokens sold.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param recipient The address that receives output ETH.
    /// @return tokensSold Amount of tokens sold.
    function tokenToEthTransferOutput(
        uint256 ethBought,
        uint256 max_tokens,
        uint256 deadline,
        address recipient
    ) external returns (uint256 tokensSold);
}
