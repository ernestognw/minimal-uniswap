// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Uniswap V1 Exchange token-to-token functions interface
/// @author Ernesto García (@ernestognw)
/// @notice Only Exchange's token-to-token functions
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
interface ITokenToToken {
    /// @notice Convert underlying tokens to tokenAddr tokens.
    /// @dev User specifies exact input and minimum output.
    /// @param tokensSold Amount of tokens sold.
    /// @param minTokensBought Minimum tokenAddr tokens purchased.
    /// @param minEthBought Minimum ETH purchased as intermediary.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param tokenAddr The address of the token being purchased.
    /// @return tokensBought Amount of tokenAddr tokens bought.
    function tokenToTokenSwapInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint64 deadline,
        address tokenAddr
    ) external returns (uint256 tokensBought);

    /// @notice Convert underlying tokens to tokenAddr tokens.
    /// @dev User specifies maximum input and exact output.
    /// @param tokensBought Amount of tokenAddr tokens bought.
    /// @param maxTokensSold Maximum underlying tokens sold.
    /// @param maxEthSold Maximum ETH purchased as intermediary.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param tokenAddr The address of the token being purchased.
    /// @return tokensSold Amount of underlying tokens sold.
    function tokenToTokenSwapOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint64 deadline,
        address tokenAddr
    ) external returns (uint256 tokensSold);

    /// @notice Convert underlying tokens to tokenAddr tokens and transfers
    ///         tokenAddr tokens to recipient.
    /// @dev User specifies exact input and minimum output.
    /// @param tokensSold Amount of tokens sold.
    /// @param minTokensBought Minimum tokenAddr tokens purchased.
    /// @param minEthBought Minimum ETH purchased as intermediary.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param recipient The address that receives output ETH.
    /// @param tokenAddr The address of the token being purchased.
    /// @return tokensBought Amount of tokenAddr tokens bought.
    function tokenToTokenTransferInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint64 deadline,
        address recipient,
        address tokenAddr
    ) external returns (uint256 tokensBought);

    /// @notice Convert underlying tokens to tokenAddr tokens and transfers
    ///         tokenAddr tokens to recipient.
    /// @dev User specifies maximum input and exact output.
    /// @param tokensBought Amount of tokenAddr tokens bought.
    /// @param maxTokensSold Maximum underlying tokens sold.
    /// @param maxEthSold Maximum ETH purchased as intermediary.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param recipient The address that receives output ETH.
    /// @param tokenAddr The address of the token being purchased.
    /// @return tokensSold Amount of underlying tokens sold.
    function tokenToTokenTransferOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint64 deadline,
        address recipient,
        address tokenAddr
    ) external returns (uint256 tokensSold);
}
