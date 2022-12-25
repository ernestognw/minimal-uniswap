// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Uniswap V1 Exchange liquidity functions interface
/// @author Ernesto García (@ernestognw)
/// @notice Only Exchange's liquidity functions
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
interface ILiquidity {
    /// ===== EVENTS ===== ///

    /// @notice Emitted when liquidity is added for a pair.
    /// @param provider The address that is providing liquidity to the pair.
    /// @param ethAmount The amount of ETH provided.
    /// @param tokenAmount The amount of tokens provided.
    event AddLiquidity(address indexed provider, uint256 indexed ethAmount, uint256 indexed tokenAmount);

    /// @notice Emitted when liquidity is removed for a pair.
    /// @param provider The address that is removing liquidity to the pair.
    /// @param ethAmount The amount of ETH removed.
    /// @param tokenAmount The amount of tokens removed.
    event RemoveLiquidity(address indexed provider, uint256 indexed ethAmount, uint256 indexed tokenAmount);

    /// @notice Deposit ETH and tokens to mint liquidity provider tokens (LPTokens).
    /// @dev minLiquidity does nothing when total LPTokens supply is 0 (no liquidity added yet).
    /// @param minLiquidity Minimum number of LPTokens sender will mint if total LPTokens supply is greater than 0.
    /// @param maxTokens Maximum number of tokens deposited. Deposits max amount if total LPTokens supply is 0.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @return minted The amount of LPTokens minted.
    function addLiquidity(uint256 minLiquidity, uint256 maxTokens, uint256 deadline)
        external
        payable
        returns (uint256 minted);

    /// @dev Burn LPTokens tokens to withdraw ETH and Tokens at current ratio.
    /// @param amount Amount of LPTokens burned.
    /// @param minEth Minimum ETH withdrawn.
    /// @param minTokens Minimum Tokens withdrawn.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @return ethAmount The amount of ETH withdrawn.
    /// @return tokenAmount The amount of tokens withdrawn.
    function removeLiquidity(uint256 amount, uint256 minEth, uint256 minTokens, uint256 deadline)
        external
        returns (uint256 ethAmount, uint256 tokenAmount);
}
