// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Uniswap V1 Exchange errors interface
/// @author Ernesto García (@ernestognw)
/// @notice Only Exchange's errors
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
interface IErrors {
    /// @notice The exchange has already been initialized.
    /// @dev Throws if the setup values are overrode when they have already been set.
    error AlreadyInitialized();

    /// @notice The exchange doesn't have enough liquidity for the operation.
    /// @dev Throws if liquidity is not enough to perform an operation
    /// @param liquidity Amount of current liquidity tokens.
    /// @param needed Amount of liquidity tokens needed at least.
    error InsufficientLiquidity(uint256 liquidity, uint256 needed);

    /// @notice The exchange doesn't have enough input reserve for the operation.
    /// @dev Throws if input reserve is not enough to perform an operation
    /// @param reserve Amount of current input reserve.
    /// @param needed Amount of input reserve needed at least.
    error InsufficientInputReserve(uint256 reserve, uint256 needed);

    /// @notice The exchange doesn't have enough output reserve for the operation.
    /// @dev Throws if output reserve is not enough to perform an operation
    /// @param reserve Amount of current output reserve.
    /// @param needed Amount of output reserve needed at least.
    error InsufficientOutputReserve(uint256 reserve, uint256 needed);

    /// @notice Tokens sold are less than the needed amount.
    /// @dev Throws if there's a requirement of tokens sold.
    /// @dev sold MUST be less than needed.
    /// @param token Address of the token that failed.
    /// @param sold Amount of tokens tried to be sold.
    /// @param needed Amount of tokens required to be sold at least.
    error InsufficientTokensSold(address token, uint256 sold, uint256 needed);

    /// @notice Tokens sold are more than the limit amount.
    /// @dev Throws if there's a requirement of tokens sold.
    /// @dev sold MUST be more than limit.
    /// @param token Address of the token that failed.
    /// @param sold Amount of tokens tried to be sold.
    /// @param limit Amount of tokens required to be sold at most.
    error ExceededTokensSold(address token, uint256 sold, uint256 limit);

    /// @notice Tokens bought are less than the needed amount.
    /// @dev Throws if there's a requirement of tokens bought.
    /// @dev bought MUST be less than needed.
    /// @param token Address of the token that failed.
    /// @param bought Amount of tokens tried to be bought.
    /// @param needed Amount of tokens required to be bought at least.
    error InsufficientTokensBought(address token, uint256 bought, uint256 needed);

    /// @notice Tokens bought are more than the limit amount.
    /// @dev Throws if there's a requirement of tokens bought.
    /// @dev bought MUST be more than limit.
    /// @param token Address of the token that failed.
    /// @param bought Amount of tokens tried to be bought.
    /// @param limit Amount of tokens required to be bought at most.
    error ExceededTokensBought(address token, uint256 bought, uint256 limit);

    /// @notice ETH sold are less than the needed amount.
    /// @dev Throws if there's a requirement of ETH sold.
    /// @dev sold MUST be less than needed.
    /// @param sold Amount of ETH tried to be sold.
    /// @param needed Amount of ETH required to be sold at least.
    error InsufficientEthSold(uint256 sold, uint256 needed);

    /// @notice ETH sold are more than the limit amount.
    /// @dev Throws if there's a requirement of ETH sold.
    /// @dev sold MUST be more than limit.
    /// @param sold Amount of ETH tried to be sold.
    /// @param limit Amount of ETH required to be sold at most.
    error ExceededEthSold(uint256 sold, uint256 limit);

    /// @notice ETH bought are less than the needed amount.
    /// @dev Throws if there's a requirement of ETH bought.
    /// @dev bought MUST be less than needed.
    /// @param bought Amount of ETH tried to be bought.
    /// @param needed Amount of ETH required to be bought at least.
    error InsufficientEthBought(uint256 bought, uint256 needed);

    /// @notice ETH bought are more than the limit amount.
    /// @dev Throws if there's a requirement of ETH bought.
    /// @dev bought MUST be more than limit.
    /// @param bought Amount of ETH tried to be bought.
    /// @param limit Amount of ETH required to be bought at most.
    error ExceededEthBought(uint256 bought, uint256 limit);

    /// @notice Transaction deadline has passed.
    /// @dev Throws if the deadline of a transaction has already passed.
    /// @dev deadline MUST be more than block.timestamp.
    error ExpiredTransaction(uint64 deadline);

    /// @notice The exchange address that's not a valid exchange.
    /// @dev Throws if the address provided is not a valid exchange.
    /// @param exchange Address that's not a valid exchange.
    error InvalidExchange(address exchange);

    /// @notice The recipient address that's not a valid recipient.
    /// @dev Throws if the address provided is not a valid recipient.
    /// @param recipient Address that's not a valid recipient.
    error InvalidRecipient(address recipient);

    /// @notice The token address that's not a valid token.
    /// @dev Throws if the address provided is not a valid token.
    /// @param token Address that's not a valid token.
    error InvalidToken(address token);
}
