// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Uniswap V1 Exchange token-to-exchange's-token functions interface
/// @author Ernesto García (@ernestognw)
/// @notice Only Exchange's token-to-exchange's-token functions
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
interface ITokenToExchangeToken {
    /// @notice Convert underlying tokens to exchangeAddr tokens.
    /// @dev Allows trades through contracts that were not deployed from the same factory.
    /// @dev User specifies exact input and minimum output.
    /// @param tokensSold Amount of tokens sold.
    /// @param minTokensBought Minimum exchangeAddr tokens purchased.
    /// @param minEthBought Minimum ETH purchased as intermediary.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param exchangeAddr The address of the exchange for the token being purchased.
    /// @return tokensBought Amount of exchangeAddr tokens bought.
    function tokenToExchangeSwapInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint64 deadline,
        address exchangeAddr
    ) external returns (uint256 tokensBought);

    /// @notice Convert underlying tokens to exchangeAddr tokens.
    /// @dev Allows trades through contracts that were not deployed from the same factory.
    /// @dev User specifies maximum input and exact output.
    /// @param tokensBought Amount of exchangeAddr tokens bought.
    /// @param maxTokensSold Maximum underlying tokens sold.
    /// @param maxEthSold Maximum ETH purchased as intermediary.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param exchangeAddr The address of the exchange for the token being purchased.
    /// @return tokensSold Amount of underlying tokens sold.
    function tokenToExchangeSwapOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint64 deadline,
        address exchangeAddr
    ) external returns (uint256 tokensSold);

    /// @notice Convert underlying tokens to exchangeAddr tokens and transfers
    ///         exchangeAddr tokens to recipient.
    /// @dev Allows trades through contracts that were not deployed from the same factory.
    /// @dev User specifies exact input and minimum output.
    /// @param tokensSold Amount of tokens sold.
    /// @param minTokensBought Minimum exchangeAddr tokens purchased.
    /// @param minEthBought Minimum ETH purchased as intermediary.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param recipient The address that receives output ETH.
    /// @param exchangeAddr The address of the exchange for the token being purchased.
    /// @return tokensBought Amount of exchangeAddr tokens bought.
    function tokenToExchangeTransferInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint64 deadline,
        address recipient,
        address exchangeAddr
    ) external returns (uint256 tokensBought);

    /// @notice Convert underlying tokens to exchangeAddr tokens and transfers
    ///         exchangeAddr tokens to recipient.
    /// @dev Allows trades through contracts that were not deployed from the same factory.
    /// @dev User specifies maximum input and exact output.
    /// @param tokensBought Amount of exchangeAddr tokens bought.
    /// @param maxTokensSold Maximum underlying tokens sold.
    /// @param maxEthSold Maximum ETH purchased as intermediary.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param recipient The address that receives output ETH.
    /// @param exchangeAddr The address of the exchange for the token being purchased.
    /// @return tokensSold Amount of underlying tokens sold.
    function tokenToExchangeTransferOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint64 deadline,
        address recipient,
        address exchangeAddr
    ) external returns (uint256 tokensSold);
}
