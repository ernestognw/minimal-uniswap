// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Uniswap V1 Factory Interface
/// @author Ernesto García (@ernestognw)
/// @notice Interface defining a Uniswap V1 Factory
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
interface IFactory {
    /// ===== EVENTS ===== ///

    /// @notice Emitted when a new exchange is created
    /// @param token Address of the exchange's underlying token
    /// @param exchange Address of the exchange
    event NewExchange(address indexed token, address indexed exchange);

    /// ===== VARIABLES ==== ///

    /// @return template Address of the exchange template.
    function exchangeTemplate() external view returns (address template);

    /// @return count Amount of tokens with an exchange.
    function tokenCount() external view returns (uint256 count);

    /// ===== EXCHANGE ===== ///

    /// @notice Creates an exchange for the provided token.
    /// @param token Address of the exchange's underlying token.
    /// @return exchange Address of the exchange.
    function createExchange(address token) external returns (address exchange);

    /// @notice Gets the exchange for the provided token.
    /// @dev Returns 0 when the token doesn't have an exchange.
    /// @param token Address of the exchange's underlying token.
    /// @return exchange Address of the exchange.
    function getExchange(
        address token
    ) external view returns (address exchange);

    /// ===== TOKEN ===== ///

    /// @notice Get an underlying token given a exchange address.
    /// @param exchange Address of the exchange.
    /// @return token Address of the exchange's underlying token.
    function getToken(address exchange) external view returns (address token);

    /// @notice Get an underlying token given a tokenId.
    /// @param tokenId Identifier of the token. Assigned during exchange creation.
    /// @return token Address of the underlying token for the tokenId.
    function getTokenWithId(
        uint256 tokenId
    ) external view returns (address token);
}
