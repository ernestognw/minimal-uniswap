// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

import {IFactory} from "./interfaces/Factory/IFactory.sol";
import {IExchange} from "./interfaces/Exchange/IExchange.sol";

/// @title Minimal Uniswap V1 Factory
/// @author Ernesto García (@ernestognw)
/// @notice A minimal Solidity implementation of a Uniswap V1 Factory
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
contract Factory is IFactory {
    using Clones for address;

    /// @inheritdoc IFactory
    address public exchangeTemplate;

    /// @inheritdoc IFactory
    uint256 public tokenCount;

    mapping(address => address) private tokenToExchange;
    mapping(address => address) private exchangeToToken;
    mapping(uint256 => address) private idToToken;

    constructor(address template) {
        exchangeTemplate = template;
    }

    /// @inheritdoc IFactory
    function createExchange(address token) external override returns (address exchange) {
        require(token != address(0));
        require(exchangeTemplate != address(0));
        require(tokenToExchange[token] != address(0));
        exchange = exchangeTemplate.clone();
        IExchange(payable(exchange)).setup(token);
        tokenToExchange[token] = exchange;
        exchangeToToken[exchange] = token;
        uint256 tokenId = tokenCount + 1;
        tokenCount = tokenId;
        idToToken[tokenId] = token;
        emit NewExchange(token, exchange);
    }

    /// @inheritdoc IFactory
    function getExchange(address token) external view override returns (address exchange) {
        return tokenToExchange[token];
    }

    /// @inheritdoc IFactory
    function getToken(address exchange) external view override returns (address token) {
        return exchangeToToken[exchange];
    }

    /// @inheritdoc IFactory
    function getTokenWithId(uint256 tokenId) external view override returns (address token) {
        return idToToken[tokenId];
    }
}
