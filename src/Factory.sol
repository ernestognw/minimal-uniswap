// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IFactory} from "./interfaces/IFactory.sol";

/// @title Minimal Uniswap V1 Factory
/// @author Ernesto García (@ernestognw)
/// @notice A minimal Solidity implementation of a Uniswap V1 Factory
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
abstract contract Factory is IFactory {
    constructor(address template) {}
}
