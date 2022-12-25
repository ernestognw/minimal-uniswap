// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IFactory} from "../Factory/IFactory.sol";

import {IPriceInfo} from "./IPriceInfo.sol";
import {ILiquidity} from "./ILiquidity.sol";
import {IETHToToken} from "./IETHToToken.sol";
import {ITokenToETH} from "./ITokenToETH.sol";
import {ITokenToToken} from "./ITokenToToken.sol";
import {ITokenToExchangeToken} from "./ITokenToExchangeToken.sol";

/// @title Uniswap V1 Exchange Interface
/// @author Ernesto García (@ernestognw)
/// @notice Interface defining a Uniswap V1 Exchange
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
interface IExchange is IPriceInfo, ILiquidity, IETHToToken, ITokenToETH, ITokenToToken, ITokenToExchangeToken {
    /// ===== EVENTS ===== ///

    /// @notice Emitted when tokens are purchased for ETH.
    /// @param buyer The address that is buying tokens for ETH.
    /// @param ethSold Amount of ETH sold for tokens.
    /// @param tokensBought Amount of tokens received.
    event TokenPurchase(address indexed buyer, uint256 indexed ethSold, uint256 indexed tokensBought);

    /// @notice Emitted when ETH is purchased for tokens.
    /// @param buyer The address that is buying ETH for tokens.
    /// @param tokensSold Amount of tokens sold for ETH.
    /// @param ethBought Amount of ETH received.
    event EthPurchase(address indexed buyer, uint256 indexed tokensSold, uint256 indexed ethBought);

    /// ===== VARIABLES ===== ///

    /// @return token Address of the underlying token sold by this exchange.
    function token() external view returns (IERC20 token);

    /// @return factory Address of the factory that created this exchange.
    function factory() external view returns (IFactory factory);
}
