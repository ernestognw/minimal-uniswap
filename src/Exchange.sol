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

/// @title Minimal Uniswap V1 Exchange
/// @author Ernesto García (@ernestognw)
/// @notice A minimal Solidity implementation of a Uniswap V1 Exchange
/// @dev Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig
abstract contract Exchange is ERC20, IExchange {
    using SafeERC20 for IERC20;

    /// @notice Address of the underlying token sold by this exchange.
    IERC20 public token;

    /// @notice Address of the factory that created this exchange.
    IFactory public factory;

    constructor(address _token, string memory name, string memory symbol) ERC20(name, symbol) {
        factory = IFactory(msg.sender);
        token = IERC20(_token);
    }

    /// @inheritdoc IPriceInfo
    function getEthToTokenInputPrice(uint256 ethSold) external view override returns (uint256 tokensToBuy) {
        require(ethSold > 0, "Exchange: Price for 0 ethSold is 0");
        return _getInputPrice(ethSold, address(this).balance, token.balanceOf(address(this)));
    }

    /// @inheritdoc IPriceInfo
    function getEthToTokenOutputPrice(uint256 tokensBought) external view override returns (uint256 ethNeeded) {
        require(tokensBought > 0, "Exchange: Price for 0 tokensBought is 0");
        return _getOutputPrice(tokensBought, address(this).balance, token.balanceOf(address(this)));
    }

    /// @inheritdoc IPriceInfo
    function getTokenToEthInputPrice(uint256 tokensSold) external view override returns (uint256 ethToBuy) {
        require(tokensSold > 0, "Exchange: Price for 0 tokensSold is 0");
        return _getInputPrice(tokensSold, token.balanceOf(address(this)), address(this).balance);
    }

    /// @inheritdoc IPriceInfo
    function getTokenToEthOutputPrice(uint256 ethBought) external view override returns (uint256 tokensNeeded) {
        require(ethBought > 0, "Exchange: Price for 0 ethBought is 0");
        return _getOutputPrice(ethBought, token.balanceOf(address(this)), address(this).balance);
    }

    /// @inheritdoc ILiquidity
    function addLiquidity(uint256 minLiquidity, uint256 maxTokens, uint64 deadline)
        external
        payable
        override
        returns (uint256 minted)
    {
        require(deadline > block.timestamp, "Exchange: Expired transaction");
        require(maxTokens > 0, "Exchange: maxTokens amount can't be 0");
        require(msg.value > 0, "Exchange: ETH amount can't be 0");

        uint256 totalLiquidity = totalSupply();

        if (totalLiquidity > 0) {
            require(minLiquidity > 0, "Exchange: minLiquidity can't be 0");
            uint256 ethReserve = address(this).balance - msg.value;
            uint256 tokenReserve = token.balanceOf(address(this));
            uint256 tokenAmount = Math.mulDiv(msg.value, tokenReserve, ethReserve);
            uint256 liquidityMinted = Math.mulDiv(msg.value, totalLiquidity, ethReserve);
            require(maxTokens >= tokenAmount, "Exchange: Token amount to deposit exceeds maxTokens");
            require(liquidityMinted >= minLiquidity, "Exchange: LPTokens to receive are less than minLiquidity");
            _mint(msg.sender, liquidityMinted);
            token.safeTransferFrom(msg.sender, address(this), tokenAmount);
            emit AddLiquidity(msg.sender, msg.value, tokenAmount);
            return liquidityMinted;
        } else {
            require(msg.value >= 1 gwei, "Exchange: Min 1 gwei ETH liquidity not met");
            assert(factory.getExchange(address(token)) == address(this));
            uint256 tokenAmount = maxTokens;
            uint256 initialLiquidity = address(this).balance;
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
        returns (uint256 ethAmount, uint256 tokenAmount)
    {
        require(deadline > block.timestamp, "Exchange: Expired transaction");
        require(amount > 0, "Exchange: amount amount can't be 0");
        require(minEth > 0, "Exchange: minEth amount can't be 0");
        require(minTokens > 0, "Exchange: minTokens amount can't be 0");

        uint256 totalLiquidity = totalSupply();
        require(totalLiquidity > 0, "Exchange: No liqiduity available");

        ethAmount = Math.mulDiv(amount, address(this).balance, totalLiquidity);
        tokenAmount = Math.mulDiv(amount, token.balanceOf(address(this)), totalLiquidity);

        require(ethAmount >= minEth, "Exchange: minEth to receive not met");
        require(tokenAmount >= minTokens, "Exchange: minTokens to receive not met");

        _burn(msg.sender, amount);

        payable(msg.sender).transfer(ethAmount);
        token.safeTransfer(msg.sender, tokenAmount);

        emit RemoveLiquidity(msg.sender, ethAmount, tokenAmount);
    }

    /// @dev Pricing function for converting between ETH and tokens.
    /// @param inputAmount Amount of ETH or tokens being sold.
    /// @param inputReserve Amount of ETH or tokens (input type) in exchange reserves.
    /// @param outputReserve Amount of ETH or tokens (output type) in exchange reserves.
    /// @return bought Amount of ETH or tokens bought.
    function _getInputPrice(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve)
        private
        pure
        returns (uint256 bought)
    {
        require(inputReserve > 0, "Can't calculate price with 0 input reserves");
        require(outputReserve > 0, "Cant' calculate price with 0 output reserves");
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
        returns (uint256 sold)
    {
        require(inputReserve > 0, "Can't calculate price with 0 input reserves");
        require(outputReserve > 0, "Cant' calculate price with 0 output reserves");
        uint256 denominator = (outputReserve - outputAmount) * 997;
        return Math.mulDiv(inputReserve, outputAmount * 1000, denominator);
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
        returns (uint256 tokensBought)
    {
        require(recipient != address(this), "Exchange: Can't buy tokens and send them to Exchange");
        require(recipient != address(0), "Exchange: Can't buy tokens and send them to ZERO_ADDRESS");
        return _ethToTokenInput(msg.value, minTokens, deadline, msg.sender, recipient);
    }

    /// @inheritdoc IETHToToken
    function ethToTokenTransferOutput(uint256 tokensBought, uint64 deadline, address recipient)
        external
        payable
        override
        returns (uint256 ethSold)
    {
        require(recipient != address(this), "Exchange: Can't buy tokens and send them to Exchange");
        require(recipient != address(0), "Exchange: Can't buy tokens and send them to ZERO_ADDRESS");
        return _ethToTokenOutput(tokensBought, msg.value, deadline, msg.sender, recipient);
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
        returns (uint256 tokensBought)
    {
        require(deadline >= block.timestamp, "Exchange: Expired transaction");
        require(minTokens > 0, "Exchange: minTokens amount can't be 0");
        require(ethSold > 0, "Exchange: ethSold amount can't be 0");
        uint256 tokenReserve = token.balanceOf(address(this));
        tokensBought = _getInputPrice(ethSold, address(this).balance - ethSold, tokenReserve);
        require(tokensBought >= minTokens, "Exchange: minTokens to receive not met");
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
        returns (uint256 ethSold)
    {
        require(deadline >= block.timestamp, "Exchange: Expired transaction");
        require(tokensBought > 0, "Exchange: tokensBought amount can't be 0");
        require(ethSold > 0, "Exchange: ethSold amount can't be 0");
        uint256 tokenReserve = token.balanceOf(address(this));
        ethSold = _getOutputPrice(tokensBought, address(this).balance - maxEth, tokenReserve);
        uint256 ethRefund = maxEth - ethSold; // Throws if ethSold > maxEth
        if (ethRefund > 0) payable(buyer).transfer(ethRefund);
        token.safeTransfer(recipient, tokensBought);
        emit TokenPurchase(buyer, ethSold, tokensBought);
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
        returns (uint256 ethBought)
    {
        require(recipient != address(this), "Exchange: Can't buy tokens and send them to Exchange");
        require(recipient != address(0), "Exchange: Can't buy tokens and send them to ZERO_ADDRESS");
        return _tokenToEthInput(tokensSold, minEth, deadline, msg.sender, recipient);
    }

    /// @inheritdoc ITokenToETH
    function tokenToEthTransferOutput(uint256 ethBought, uint256 maxTokens, uint64 deadline, address recipient)
        external
        returns (uint256 tokensSold)
    {
        require(recipient != address(this), "Exchange: Can't buy tokens and send them to Exchange");
        require(recipient != address(0), "Exchange: Can't buy tokens and send them to ZERO_ADDRESS");
        return _tokenToEthOutput(ethBought, maxTokens, deadline, msg.sender, recipient);
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
        returns (uint256 ethBought)
    {
        require(deadline >= block.timestamp, "Exchange: Expired transaction");
        require(tokensSold > 0, "Exchange: tokensSold amount can't be 0");
        require(minEth > 0, "Exchange: minEth amount can't be 0");
        ethBought = _getInputPrice(tokensSold, token.balanceOf(address(this)), address(this).balance);
        require(ethBought >= minEth, "Exchange: minEth to receive not met");
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
        returns (uint256 tokensSold)
    {
        require(deadline >= block.timestamp, "Exchange: Expired transaction");
        require(ethBought > 0, "Exchange: ethBought amount can't be 0");
        tokensSold = _getOutputPrice(ethBought, token.balanceOf(address(this)), address(this).balance);
        require(maxTokens >= tokensSold, "Exchange: maxTokens to send exceeded");
        payable(recipient).transfer(ethBought);
        token.safeTransferFrom(buyer, address(this), tokensSold);
        emit EthPurchase(buyer, tokensSold, ethBought);
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
    ) private returns (uint256 tokensBought) {
        require(deadline >= block.timestamp, "Exchange: Expired transaction");
        require(tokensSold > 0, "Exchange: tokensSold amount can't be 0");
        require(minTokensBought > 0, "Exchange: minTokensBought amount can't be 0");
        require(minEthBought > 0, "Exchange: minEthBought amount can't be 0");
        require(exchangeAddr != address(this), "Exchange: Can't trade tokens with themselves");
        require(exchangeAddr != address(0), "Exchange: ZERO_ADDRESS is not an exchange");
        uint256 ethBought = _getInputPrice(tokensSold, token.balanceOf(address(this)), address(this).balance);
        require(ethBought >= minEthBought, "Exchange: minEthBought to receive not met");
        token.safeTransferFrom(buyer, address(this), tokensSold);
        tokensBought = IExchange(payable(exchangeAddr)).ethToTokenTransferInput{value: ethBought}(
            minTokensBought, deadline, recipient
        );
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
    ) private returns (uint256 tokensSold) {
        require(deadline >= block.timestamp, "Exchange: Expired transaction");
        require(tokensBought > 0, "Exchange: tokensBought amount can't be 0");
        require(maxEthSold > 0, "Exchange: maxEthSold amount can't be 0");
        uint256 ethBought = Exchange(payable(exchangeAddr)).getEthToTokenOutputPrice(tokensBought);
        tokensSold = _getOutputPrice(ethBought, token.balanceOf(address(this)), address(this).balance);
        assert(tokensSold > 0);
        require(maxTokensSold >= tokensSold, "Exchange: maxTokensSold to send exceeded");
        require(maxEthSold >= ethBought, "Exchange: maxEthSold exceeded");
        token.safeTransferFrom(buyer, address(this), tokensSold);
        Exchange(payable(exchangeAddr)).ethToTokenTransferOutput{value: ethBought}(tokensBought, deadline, recipient);
        emit EthPurchase(buyer, tokensSold, ethBought);
    }
}
