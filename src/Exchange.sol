// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IExchange} from "./interfaces/Exchange/IExchange.sol";
import {IFactory} from "./interfaces/Factory/IFactory.sol";

/// Only for @inheritdoc
import {IPriceInfo} from "./interfaces/Exchange/IPriceInfo.sol";
import {ILiquidity} from "./interfaces/Exchange/ILiquidity.sol";
import {IETHToToken} from "./interfaces/Exchange/IETHToToken.sol";
import {ITokenToETH} from "./interfaces/Exchange/ITokenToETH.sol";
import {ITokenToToken} from "./interfaces/Exchange/ITokenToToken.sol";
import {ITokenToExchangeToken} from "./interfaces/Exchange/ITokenToExchangeToken.sol";

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

    /// @notice Override name
    string private _name;

    /// @notice Override symbol
    string private _symbol;

    /// @dev Requires a deadline that hasn't expired
    /// @param deadline Time after which this transaction can no longer be executed.
    modifier notExpired(uint64 deadline) {
        if (deadline < block.timestamp) revert ExpiredTransaction(deadline);
        _;
    }

    /// @dev Requires sold to be > 0
    /// @param tokenAddr Address of the token sold
    /// @param sold Amount of tokens sold
    modifier requireTokensSold(address tokenAddr, uint256 sold) {
        if (sold <= 0) revert InsufficientTokensSold(tokenAddr, sold, 1);
        _;
    }

    /// @dev Requires bought to be > 0
    /// @param tokenAddr Address of the token bought
    /// @param bought Amount of tokens bought
    modifier requireTokensBought(address tokenAddr, uint256 bought) {
        if (bought <= 0) revert InsufficientTokensBought(tokenAddr, bought, 1);
        _;
    }

    /// @dev Requires sold to be > 0
    /// @param sold Amount of ETH sold
    modifier requireEthSold(uint256 sold) {
        if (sold <= 0) revert InsufficientEthSold(sold, 1);
        _;
    }

    /// @dev Requires bought to be > 0
    /// @param bought Amount of ETH bought
    modifier requireEthBought(uint256 bought) {
        if (bought <= 0) revert InsufficientEthBought(bought, 1);
        _;
    }

    /// @dev Checks if recipient is valid
    /// @param recipient address to check
    modifier requireValidRecipient(address recipient) {
        if (recipient == address(this) || recipient == address(0)) revert InvalidRecipient(recipient);
        _;
    }

    /// @dev Checks if reserves are > 0
    /// @param inputReserve reserve of the input asset
    /// @param outputReserve reserve of the output asset
    modifier requireReserves(uint256 inputReserve, uint256 outputReserve) {
        if (inputReserve <= 0) revert InsufficientInputReserve(inputReserve, 1);
        if (outputReserve <= 0) revert InsufficientOutputReserve(outputReserve, 1);
        _;
    }

    constructor() ERC20("Uniswap V1 Template", "UNI-TMP") {}

    /// @dev This function acts as a contract constructor which is not currently supported in contracts deployed
    ///      using ERC 1167 minimal proxy. It is called once by the factory during contract creation.
    function setup(address _token, string memory name, string memory symbol) public {
        if (address(factory) != address(0) || address(token) != address(0)) revert AlreadyInitialized();
        if (_token == address(0)) revert InvalidToken(_token);
        factory = IFactory(msg.sender);
        token = IERC20(_token);
        _name = name;
        _symbol = symbol;
    }

    /// @inheritdoc IPriceInfo
    function getEthToTokenInputPrice(uint256 ethSold)
        external
        view
        override
        requireEthSold(ethSold)
        returns (uint256 tokensToBuy)
    {
        return _getInputPrice(ethSold, _ethReserve(), _tokenReserve());
    }

    /// @inheritdoc IPriceInfo
    function getEthToTokenOutputPrice(uint256 tokensBought)
        external
        view
        override
        requireTokensBought(address(token), tokensBought)
        returns (uint256 ethNeeded)
    {
        return _getOutputPrice(tokensBought, _ethReserve(), _tokenReserve());
    }

    /// @inheritdoc IPriceInfo
    function getTokenToEthInputPrice(uint256 tokensSold)
        external
        view
        override
        requireTokensSold(address(token), tokensSold)
        returns (uint256 ethToBuy)
    {
        return _getInputPrice(tokensSold, _tokenReserve(), _ethReserve());
    }

    /// @inheritdoc IPriceInfo
    function getTokenToEthOutputPrice(uint256 ethBought)
        external
        view
        override
        requireEthBought(ethBought)
        returns (uint256 tokensNeeded)
    {
        return _getOutputPrice(ethBought, _tokenReserve(), _ethReserve());
    }

    /// @inheritdoc ILiquidity
    function addLiquidity(uint256 minLiquidity, uint256 maxTokens, uint64 deadline)
        external
        payable
        override
        notExpired(deadline)
        requireTokensSold(address(token), maxTokens)
        requireEthSold(msg.value)
        returns (uint256 minted)
    {
        uint256 totalLiquidity = totalSupply();

        if (totalLiquidity > 0) {
            if (minLiquidity <= 0) revert InsufficientTokensBought(address(this), minLiquidity, 1);
            uint256 ethReserve = _ethReserve(msg.value);
            uint256 tokenAmount = Math.mulDiv(msg.value, _tokenReserve(), ethReserve);
            uint256 liquidityMinted = Math.mulDiv(msg.value, totalLiquidity, ethReserve);
            if (maxTokens < tokenAmount) revert ExceededTokensSold(address(token), tokenAmount, maxTokens);
            if (liquidityMinted < minLiquidity) revert ExceededTokensBought(address(this), liquidityMinted, minLiquidity);
            _mint(msg.sender, liquidityMinted);
            token.safeTransferFrom(msg.sender, address(this), tokenAmount);
            emit AddLiquidity(msg.sender, msg.value, tokenAmount);
            return liquidityMinted;
        } else {
            if (msg.value < 1 gwei) revert InsufficientEthSold(msg.value, 1 gwei);
            assert(factory.getExchange(address(token)) == address(this));
            uint256 tokenAmount = maxTokens;
            uint256 initialLiquidity = _ethReserve();
            _mint(msg.sender, initialLiquidity);
            token.safeTransferFrom(msg.sender, address(this), tokenAmount);
            emit AddLiquidity(msg.sender, msg.value, tokenAmount);
            return initialLiquidity;
        }
    }

    /// @inheritdoc ILiquidity
    function removeLiquidity(uint256 amount, uint256 minEth, uint256 minTokens, uint64 deadline)
        external
        override
        notExpired(deadline)
        requireTokensSold(address(this), amount)
        requireEthBought(minEth)
        requireTokensBought(address(token), minTokens)
        returns (uint256 ethAmount, uint256 tokenAmount)
    {
        uint256 totalLiquidity = totalSupply();
        if (totalLiquidity <= 0) revert InsufficientLiquidity(totalLiquidity, 1);

        ethAmount = Math.mulDiv(amount, _ethReserve(), totalLiquidity);
        tokenAmount = Math.mulDiv(amount, _tokenReserve(), totalLiquidity);

        if (ethAmount < minEth) revert InsufficientEthBought(ethAmount, minEth);
        if (tokenAmount < minTokens) revert InsufficientTokensBought(address(token), tokenAmount, minTokens);

        _burn(msg.sender, amount);

        payable(msg.sender).transfer(ethAmount);
        token.safeTransfer(msg.sender, tokenAmount);

        emit RemoveLiquidity(msg.sender, ethAmount, tokenAmount);
    }

    /// @inheritdoc IETHToToken
    receive() external payable {
        _ethToTokenInput(msg.value, 1, uint64(block.timestamp), msg.sender, msg.sender);
    }

    /// @inheritdoc IETHToToken
    fallback() external payable {
        _ethToTokenInput(msg.value, 1, uint64(block.timestamp), msg.sender, msg.sender);
    }

    /// @inheritdoc IETHToToken
    function ethToTokenSwapInput(uint256 minTokens, uint64 deadline)
        external
        payable
        override
        returns (uint256 tokensBought)
    {
        return _ethToTokenInput(msg.value, minTokens, deadline, msg.sender, msg.sender);
    }

    /// @inheritdoc IETHToToken
    function ethToTokenSwapOutput(uint256 tokensBought, uint64 deadline)
        external
        payable
        override
        returns (uint256 ethSold)
    {
        return _ethToTokenOutput(tokensBought, msg.value, deadline, msg.sender, msg.sender);
    }

    /// @inheritdoc IETHToToken
    function ethToTokenTransferInput(uint256 minTokens, uint64 deadline, address recipient)
        external
        payable
        override
        requireValidRecipient(recipient)
        returns (uint256 tokensBought)
    {
        return _ethToTokenInput(msg.value, minTokens, deadline, msg.sender, recipient);
    }

    /// @inheritdoc IETHToToken
    function ethToTokenTransferOutput(uint256 tokensBought, uint64 deadline, address recipient)
        external
        payable
        override
        requireValidRecipient(recipient)
        returns (uint256 ethSold)
    {
        return _ethToTokenOutput(tokensBought, msg.value, deadline, msg.sender, recipient);
    }

    /// @inheritdoc ITokenToETH
    function tokenToEthSwapInput(uint256 tokensSold, uint256 minEth, uint64 deadline)
        external
        returns (uint256 ethBought)
    {
        return _tokenToEthInput(tokensSold, minEth, deadline, msg.sender, msg.sender);
    }

    /// @inheritdoc ITokenToETH
    function tokenToEthSwapOutput(uint256 ethBought, uint256 maxTokens, uint64 deadline)
        external
        returns (uint256 tokensSold)
    {
        return _tokenToEthOutput(ethBought, maxTokens, deadline, msg.sender, msg.sender);
    }

    /// @inheritdoc ITokenToETH
    function tokenToEthTransferInput(uint256 tokensSold, uint256 minEth, uint64 deadline, address recipient)
        external
        requireValidRecipient(recipient)
        returns (uint256 ethBought)
    {
        return _tokenToEthInput(tokensSold, minEth, deadline, msg.sender, recipient);
    }

    /// @inheritdoc ITokenToETH
    function tokenToEthTransferOutput(uint256 ethBought, uint256 maxTokens, uint64 deadline, address recipient)
        external
        requireValidRecipient(recipient)
        returns (uint256 tokensSold)
    {
        return _tokenToEthOutput(ethBought, maxTokens, deadline, msg.sender, recipient);
    }

    /// @inheritdoc ITokenToToken
    function tokenToTokenSwapInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint64 deadline,
        address tokenAddr
    ) external returns (uint256 tokensBought) {
        return _tokenToTokenInput(
            tokensSold, minTokensBought, minEthBought, deadline, msg.sender, msg.sender, factory.getExchange(tokenAddr)
        );
    }

    /// @inheritdoc ITokenToToken
    function tokenToTokenSwapOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint64 deadline,
        address tokenAddr
    ) external returns (uint256 tokensSold) {
        return _tokenToTokenOutput(
            tokensBought, maxTokensSold, maxEthSold, deadline, msg.sender, msg.sender, factory.getExchange(tokenAddr)
        );
    }

    /// @inheritdoc ITokenToToken
    function tokenToTokenTransferInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint64 deadline,
        address recipient,
        address tokenAddr
    ) external returns (uint256 tokensBought) {
        return _tokenToTokenInput(
            tokensSold, minTokensBought, minEthBought, deadline, msg.sender, recipient, factory.getExchange(tokenAddr)
        );
    }

    /// @inheritdoc ITokenToToken
    function tokenToTokenTransferOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint64 deadline,
        address recipient,
        address tokenAddr
    ) external returns (uint256 tokensSold) {
        return _tokenToTokenOutput(
            tokensBought, maxTokensSold, maxEthSold, deadline, msg.sender, recipient, factory.getExchange(tokenAddr)
        );
    }

    /// @inheritdoc ITokenToExchangeToken
    function tokenToExchangeSwapInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint64 deadline,
        address exchangeAddr
    ) external returns (uint256 tokensBought) {
        return _tokenToTokenInput(
            tokensSold, minTokensBought, minEthBought, deadline, msg.sender, msg.sender, exchangeAddr
        );
    }

    /// @inheritdoc ITokenToExchangeToken
    function tokenToExchangeSwapOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint64 deadline,
        address exchangeAddr
    ) external returns (uint256 tokensSold) {
        return
            _tokenToTokenOutput(tokensBought, maxTokensSold, maxEthSold, deadline, msg.sender, msg.sender, exchangeAddr);
    }

    /// @inheritdoc ITokenToExchangeToken
    function tokenToExchangeTransferInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint64 deadline,
        address recipient,
        address exchangeAddr
    ) external requireValidRecipient(recipient) returns (uint256 tokensBought) {
        return
            _tokenToTokenInput(tokensSold, minTokensBought, minEthBought, deadline, msg.sender, recipient, exchangeAddr);
    }

    /// @inheritdoc ITokenToExchangeToken
    function tokenToExchangeTransferOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint64 deadline,
        address recipient,
        address exchangeAddr
    ) external requireValidRecipient(recipient) returns (uint256 tokensSold) {
        return
            _tokenToTokenOutput(tokensBought, maxTokensSold, maxEthSold, deadline, msg.sender, recipient, exchangeAddr);
    }

    /// @dev Amount of reserves in tokens
    function _tokenReserve() private view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /// @dev Amount of reserves in ETH without adjustment
    function _ethReserve() private view returns (uint256) {
        return _ethReserve(0);
    }

    /// @dev Amount of reserves in ETH
    /// @dev It allows to substract an amount to adjust to different scenarios,
    ///      (e.g.) eth reserves are incremented before executing a payable function
    /// @param adjustment Amount to substract from the current balance of the contract (0 by default)
    function _ethReserve(uint256 adjustment) private view returns (uint256) {
        return address(this).balance - adjustment;
    }

    /// @dev Pricing function for converting between ETH and tokens.
    /// @param inputAmount Amount of ETH or tokens being sold.
    /// @param inputReserve Amount of ETH or tokens (input type) in exchange reserves.
    /// @param outputReserve Amount of ETH or tokens (output type) in exchange reserves.
    /// @return bought Amount of ETH or tokens bought.
    function _getInputPrice(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve)
        private
        pure
        requireReserves(inputReserve, outputReserve)
        returns (uint256 bought)
    {
        uint256 inputAmountWithFee = inputAmount * 997;
        uint256 denominator = (inputReserve * 1000) + inputAmountWithFee;
        return Math.mulDiv(inputAmountWithFee, outputReserve, denominator);
    }

    /// @dev Pricing function for converting between ETH and tokens.
    /// @param outputAmount Amount of ETH or tokens being bought.
    /// @param inputReserve Amount of ETH or tokens (input type) in exchange reserves.
    /// @param outputReserve Amount of ETH or tokens (output type) in exchange reserves.
    /// @return sold Amount of ETH or tokens sold.
    function _getOutputPrice(uint256 outputAmount, uint256 inputReserve, uint256 outputReserve)
        private
        pure
        requireReserves(inputReserve, outputReserve)
        returns (uint256 sold)
    {
        uint256 denominator = (outputReserve - outputAmount) * 997;
        return Math.mulDiv(inputReserve, outputAmount * 1000, denominator);
    }

    /// @dev Transfers an amount of tokens based on ETH sold.
    /// @param ethSold Amount of ETH being sold.
    /// @param minTokens Minimum tokens bought.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param buyer The address that sent the ETH sold.
    /// @param recipient The address that receives the tokens bought.
    /// @return tokensBought Amount of tokens sold.
    function _ethToTokenInput(uint256 ethSold, uint256 minTokens, uint64 deadline, address buyer, address recipient)
        private
        notExpired(deadline)
        requireTokensBought(address(token), minTokens)
        requireEthSold(ethSold)
        returns (uint256 tokensBought)
    {
        tokensBought = _getInputPrice(ethSold, _ethReserve(ethSold), _tokenReserve());
        if (tokensBought < minTokens) revert InsufficientTokensBought(address(token), tokensBought, minTokens);
        token.transfer(recipient, tokensBought);
        emit TokenPurchase(buyer, ethSold, tokensBought);
    }

    /// @dev Transfers an amount of tokens bought.
    /// @param tokensBought Amount of tokens being bought.
    /// @param maxEth Maximum ETH sold.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param buyer The address that sent the ETH sold.
    /// @param recipient The address that receives the tokens bought.
    /// @return ethSold Amount of ETH sold.
    function _ethToTokenOutput(uint256 tokensBought, uint256 maxEth, uint64 deadline, address buyer, address recipient)
        private
        notExpired(deadline)
        requireTokensBought(address(token), tokensBought)
        requireEthSold(ethSold)
        returns (uint256 ethSold)
    {
        ethSold = _getOutputPrice(tokensBought, _ethReserve(maxEth), _tokenReserve());
        if (ethSold < maxEth) revert ExceededEthBought(ethSold, maxEth);
        uint256 ethRefund = maxEth - ethSold;
        if (ethRefund > 0) payable(buyer).transfer(ethRefund);
        token.safeTransfer(recipient, tokensBought);
        emit TokenPurchase(buyer, ethSold, tokensBought);
    }

    /// @dev Transfers an amount of ETH based on tokens sold.
    /// @param tokensSold Amount of tokens being sold.
    /// @param minEth Minimum ETH bought.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param buyer The address that sent the tokens sold.
    /// @param recipient The address that receives the ETH bought.
    /// @return ethBought Amount of ETH bought.
    function _tokenToEthInput(uint256 tokensSold, uint256 minEth, uint64 deadline, address buyer, address recipient)
        private
        notExpired(deadline)
        requireTokensSold(address(token), tokensSold)
        requireEthBought(minEth)
        returns (uint256 ethBought)
    {
        ethBought = _getInputPrice(tokensSold, _tokenReserve(), _ethReserve());
        if (ethBought < minEth) revert InsufficientEthBought(ethBought, minEth);
        payable(recipient).transfer(ethBought);
        token.safeTransferFrom(buyer, address(this), tokensSold);
        emit EthPurchase(buyer, tokensSold, ethBought);
    }

    /// @dev Transfers an amount of ETH bought.
    /// @param ethBought Amount of ETH being bought.
    /// @param maxTokens Maximum tokens sold.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param buyer The address that sent the tokens sold.
    /// @param recipient The address that receives the ETH bought.
    /// @return tokensSold Amount of tokens sold.
    function _tokenToEthOutput(uint256 ethBought, uint256 maxTokens, uint64 deadline, address buyer, address recipient)
        private
        notExpired(deadline)
        requireEthBought(ethBought)
        returns (uint256 tokensSold)
    {
        tokensSold = _getOutputPrice(ethBought, _tokenReserve(), _ethReserve());
        if (maxTokens < tokensSold) revert ExceededTokensSold(address(token), tokensSold, maxTokens);
        payable(recipient).transfer(ethBought);
        token.safeTransferFrom(buyer, address(this), tokensSold);
        emit EthPurchase(buyer, tokensSold, ethBought);
    }

    /// @dev Transfers an amount of exchangeAddr tokens based on tokens sold.
    /// @param tokensSold Amount of tokens being sold.
    /// @param minTokensBought Minimum exchangeAddr tokens bought.
    /// @param minEthBought Minimum ETH bought.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param buyer The address that sent the tokens sold.
    /// @param recipient The address that receives the exchangeAddr tokens bought.
    /// @param exchangeAddr The address of the exchange of the token purchased.
    /// @return tokensBought Amount of exchangeAddr tokens bought.
    function _tokenToTokenInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint64 deadline,
        address buyer,
        address recipient,
        address exchangeAddr
    )
        private
        notExpired(deadline)
        requireTokensSold(address(token), tokensSold)
        requireEthBought(minEthBought)
        returns (uint256 tokensBought)
    {
        IExchange exchange = IExchange(payable(exchangeAddr));
        if (minTokensBought <= 0) revert InsufficientTokensBought(address(exchange.token()), minTokensBought, 1);
        if (exchangeAddr == address(this) || exchangeAddr == address(0)) revert InvalidExchange(exchangeAddr);
        uint256 ethBought = _getInputPrice(tokensSold, _tokenReserve(), _ethReserve());
        if (ethBought < minEthBought) revert InsufficientEthBought(ethBought, minEthBought);
        token.safeTransferFrom(buyer, address(this), tokensSold);
        tokensBought = exchange.ethToTokenTransferInput{value: ethBought}(minTokensBought, deadline, recipient);
        emit EthPurchase(buyer, tokensSold, ethBought);
    }

    /// @dev Transfers an amount exchangeAddr tokens bought.
    /// @param tokensBought Amount of exchangeAddr tokens being bought.
    /// @param maxTokensSold Maximum tokens sold.
    /// @param maxEthSold Maximum ETH sold.
    /// @param deadline Time after which this transaction can no longer be executed.
    /// @param buyer The address that sent the tokens sold.
    /// @param recipient The address that receives the exchangeAddr tokens bought.
    /// @param exchangeAddr The address of the exchange of the token purchased.
    /// @return tokensSold Amount of tokens sold.
    function _tokenToTokenOutput(
        uint256 tokensBought,
        uint256 maxTokensSold,
        uint256 maxEthSold,
        uint64 deadline,
        address buyer,
        address recipient,
        address exchangeAddr
    ) private notExpired(deadline) requireEthSold(maxEthSold) returns (uint256 tokensSold) {
        IExchange exchange = IExchange(payable(exchangeAddr));
        if (tokensBought <= 0) revert InsufficientTokensBought(address(exchange.token()), tokensBought, 1);
        uint256 ethBought = exchange.getEthToTokenOutputPrice(tokensBought);
        tokensSold = _getOutputPrice(ethBought, _tokenReserve(), _ethReserve());
        assert(tokensSold > 0);
        if (maxTokensSold < tokensSold) revert ExceededTokensSold(address(token), tokensSold, maxTokensSold);
        if (maxEthSold < ethBought) revert ExceededEthBought(ethBought, maxEthSold);
        token.safeTransferFrom(buyer, address(this), tokensSold);
        exchange.ethToTokenTransferOutput{value: ethBought}(tokensBought, deadline, recipient);
        emit EthPurchase(buyer, tokensSold, ethBought);
    }
}
