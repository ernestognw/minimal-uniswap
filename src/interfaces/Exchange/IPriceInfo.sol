// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Uniswap V1 Exchange price info functions interface
/// @author Ernesto García (@ernestognw)
/// @notice Only Exchange's price info functions
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
interface IPriceInfo {
    /// @notice Public price function for ETH to token trades with an exact input.
    /// @param ethSold Amount of ETH sold.
    /// @return tokensToBuy Amount of tokens that can be bought with input ETH.
    function getEthToTokenInputPrice(
        uint256 ethSold
    ) external view returns (uint256 tokensToBuy);

    /// @notice Public price function for ETH to token trades with an exact output.
    /// @param tokensBought Amount of tokens bought.
    /// @return ethNeeded Amount of ETH needed to buy output token.
    function getEthToTokenOutputPrice(
        uint256 tokensBought
    ) external view returns (uint256 ethNeeded);

    /// @notice Public price function for token to ETH trades with an exact input.
    /// @param tokensSold Amount of tokens sold.
    /// @return ethToBuy Amount of ETH that can be bought with input tokens.
    function getTokenToEthInputPrice(
        uint256 tokensSold
    ) external view returns (uint256 ethToBuy);

    /// @notice Public price function for token to ETH trades with an exact output.
    /// @param ethBought Amount of output ETH.
    /// @return tokensNeeded Amount of tokens needed to buy output ETH.
    function getTokenToEthOutputPrice(
        uint256 ethBought
    ) external view returns (uint256 tokensNeeded);
}
