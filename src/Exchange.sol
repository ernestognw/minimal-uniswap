// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IExchange} from "./interfaces/Exchange/IExchange.sol";
import {IFactory} from "./interfaces/Factory/IFactory.sol";

/// @title Minimal Uniswap V1 Exchange
/// @author Ernesto García (@ernestognw)
/// @notice A minimal Solidity implementation of a Uniswap V1 Exchange
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
contract Exchange is ERC20, IExchange {
    using SafeERC20 for IERC20;

    /// @notice Address of the underlying token sold by this exchange.
    IERC20 public token;

    /// @notice Address of the factory that created this exchange.
    IFactory public factory;

    constructor(
        address _token,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        factory = IFactory(msg.sender);
        token = IERC20(_token);
    }
}
