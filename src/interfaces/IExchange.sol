// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./IFactory.sol";

/// @title Uniswap V1 Exchange Interface
/// @author Ernesto García (@ernestognw)
/// @notice Interface defining a Uniswap V1 Exchange
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
interface IExchange {
    /// ===== EVENTS ===== ///

    /// @notice Emitted when tokens are purchased for ETH.
    /// @param buyer The address that is buying tokens for ETH.
    /// @param ethSold Amount of ETH sold for tokens.
    /// @param tokensBought Amount of tokens received.
    event TokenPurchase(
        address indexed buyer,
        uint256 indexed ethSold,
        uint256 indexed tokensBought
    );

    /// @notice Emitted when ETH is purchased for tokens.
    /// @param buyer The address that is buying ETH for tokens.
    /// @param tokensSold Amount of tokens sold for ETH.
    /// @param ethBought Amount of ETH received.
    event EthPurchase(
        address indexed buyer,
        uint256 indexed tokensSold,
        uint256 indexed ethBought
    );

    /// @notice Emitted when liquidity is added for a pair.
    /// @param provider The address that is providing liquidity to the pair.
    /// @param ethAmount The amount of ETH provided.
    /// @param tokenAmount The amount of tokens provided.
    event AddLiquidity(
        address indexed provider,
        uint256 indexed ethAmount,
        uint256 indexed tokenAmount
    );

    /// @notice Emitted when liquidity is removed for a pair.
    /// @param provider The address that is removing liquidity to the pair.
    /// @param ethAmount The amount of ETH removed.
    /// @param tokenAmount The amount of tokens removed.
    event RemoveLiquidity(
        address indexed provider,
        uint256 indexed ethAmount,
        uint256 indexed tokenAmount
    );

    /// ===== VARIABLES ===== ///

    /// @return token Address of the underlying token sold by this exchange.
    function token() external view returns (address token);

    /// @return factory Address of the factory that created this exchange.
    function factory() external view returns (address factory);

    /// ===== INFO ===== ///

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

    /// ===== LIQUIDITY ===== ///

    /// @notice Deposit ETH and tokens to mint liquidity provider tokens (LPTokens).
    /// @dev minLiquidity does nothing when total LPTokens supply is 0 (no liquidity added yet).
    /// @param minLiquidity Minimum number of LPTokens sender will mint if total LPTokens supply is greater than 0.
    /// @param maxTokens Maximum number of tokens deposited. Deposits max amount if total LPTokens supply is 0.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @return minted The amount of LPTokens minted.
    function addLiquidity(
        uint256 minLiquidity,
        uint256 maxTokens,
        uint256 deadline
    ) external payable returns (uint256 minted);

    /// @dev Burn LPTokens tokens to withdraw ETH and Tokens at current ratio.
    /// @param amount Amount of LPTokens burned.
    /// @param minEth Minimum ETH withdrawn.
    /// @param minTokens Minimum Tokens withdrawn.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @return ethAmount The amount of ETH withdrawn.
    /// @return tokenAmount The amount of tokens withdrawn.
    function removeLiquidity(
        uint256 amount,
        uint256 minEth,
        uint256 minTokens,
        uint256 deadline
    ) external returns (uint256 ethAmount, uint256 tokenAmount);

    /// ===== ETH TO TOKEN ===== ///

    /// @notice Convert ETH to tokens.
    /// @dev User specifies exact input (msg.value) and minimum output.
    /// @param minTokens Minimum tokens bought.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @return tokensBought Amount of tokens bought.
    function ethToTokenSwapInput(
        uint256 minTokens,
        uint256 deadline
    ) external payable returns (uint256 tokensBought);

    /// @notice Convert ETH to tokens.
    /// @dev User specifies maximum input (msg.value) and exact output.
    /// @param tokensBought Amount of tokens bought.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @return ethSold Amount of ETH sold.
    function ethToTokenSwapOutput(
        uint256 tokensBought,
        uint256 deadline
    ) external payable returns (uint256 ethSold);

    /// @notice Convert ETH to tokens and transfers tokens to recipient.
    /// @dev User specifies exact input (msg.value) and minimum output
    /// @param minTokens Minimum tokens bought.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param recipient The address that receives output tokens.
    /// @return tokensBought Amount of tokens bought.
    function ethToTokenTransferInput(
        uint256 minTokens,
        uint256 deadline,
        address recipient
    ) external payable returns (uint256 tokensBought);

    /// @notice Convert ETH to tokens and transfers tokens to recipient.
    /// @dev User specifies maximum input (msg.value) and exact output.
    /// @param tokensBought Amount of tokens bought.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param recipient The address that receives output tokens.
    /// @return ethSold Amount of ETH sold.
    function ethToTokenTransferOutput(
        uint256 tokensBought,
        uint256 deadline,
        address recipient
    ) external payable returns (uint256 ethSold);

    /// ===== TOKEN TO ETH ===== ///

    /// @notice Convert Tokens to ETH.
    /// @dev User specifies exact input and minimum output.
    /// @param tokensSold Amount of Tokens sold.
    /// @param minEth Minimum ETH purchased.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @return ethBought Amount of ETH bought.
    function tokenToEthSwapInput(
        uint256 tokensSold,
        uint256 minEth,
        uint256 deadline
    ) external returns (uint256 ethBought);

    /// @notice Convert tokens to ETH.
    /// @dev User specifies maximum input and exact output.
    /// @param ethBought Amount of ETH purchased.
    /// @param maxTokens Maximum tokens sold.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @return tokensSold Amount of tokens sold.
    function tokenToEthSwapOutput(
        uint256 ethBought,
        uint256 maxTokens,
        uint256 deadline
    ) external returns (uint256 tokensSold);

    /// @notice Convert tokens to ETH and transfers ETH to recipient.
    /// @dev User specifies exact input and minimum output.
    /// @param tokensSold Amount of tokens sold.
    /// @param minEth Minimum ETH purchased.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param recipient The address that receives output ETH.
    /// @return ethBought Amount of ETH bought.
    function tokenToEthTransferInput(
        uint256 tokensSold,
        uint256 minEth,
        uint256 deadline,
        address recipient
    ) external returns (uint256 ethBought);

    /// @notice Convert tokens to ETH and transfers ETH to recipient.
    /// @dev User specifies maximum input and exact output.
    /// @param ethBought Amount of ETH purchased.
    /// @param max_tokens Maximum tokens sold.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param recipient The address that receives output ETH.
    /// @return tokensSold Amount of tokens sold.
    function tokenToEthTransferOutput(
        uint256 ethBought,
        uint256 max_tokens,
        uint256 deadline,
        address recipient
    ) external returns (uint256 tokensSold);

    /// ===== TOKEN TO TOKEN ===== ///

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
        uint256 deadline,
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
        uint256 deadline,
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
        uint256 deadline,
        address recipient,
        address tokenAddr
    ) external returns (uint256 tokensBought);

    /// @notice Convert underlying tokens to tokenAddr tokens and transfers
    ///         tokenAddr tokens to recipient.
    /// @dev User specifies maximum input and exact output.
    /// @param tokens_bought Amount of tokenAddr tokens bought.
    /// @param maxTokensSold Maximum underlying tokens sold.
    /// @param maxEthSold Maximum ETH purchased as intermediary.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param recipient The address that receives output ETH.
    /// @param tokenAddr The address of the token being purchased.
    /// @return tokensSold Amount of underlying tokens sold.
    function tokenToTokenTransferOutput(
        uint256 tokens_bought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint256 deadline,
        address recipient,
        address tokenAddr
    ) external returns (uint256 tokensSold);

    /// ===== TOKEN TO EXCHANGE TOKEN ===== ///

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
        uint256 deadline,
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
        uint256 deadline,
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
        uint256 deadline,
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
        uint256 deadline,
        address recipient,
        address exchangeAddr
    ) external returns (uint256 tokensSold);
}
