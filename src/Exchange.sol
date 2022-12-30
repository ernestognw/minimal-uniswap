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

    function getEthToTokenInputPrice(uint256 ethSold) external view override returns (uint256 tokensToBuy) {
        require(ethSold > 0, "Price for 0 ethSold is 0");
        return getInputPrice(ethSold, address(this).balance, token.balanceOf(address(this)));
    }

    function getEthToTokenOutputPrice(uint256 tokensBought) external view override returns (uint256 ethNeeded) {
        require(tokensBought > 0, "Price for 0 tokensBought is 0");
        return getOutputPrice(tokensBought, address(this).balance, token.balanceOf(address(this)));
    }

    function getTokenToEthInputPrice(uint256 tokensSold) external view override returns (uint256 ethToBuy) {
        require(tokensSold > 0, "Price for 0 tokensSold is 0");
        return getInputPrice(tokensSold, token.balanceOf(address(this)), address(this).balance);
    }

    function getTokenToEthOutputPrice(uint256 ethBought) external view override returns (uint256 tokensNeeded) {
        require(ethBought > 0, "Price for 0 ethBought is 0");
        return getOutputPrice(ethBought, token.balanceOf(address(this)), address(this).balance);
    }

    function addLiquidity(uint256 minLiquidity, uint256 maxTokens, uint256 deadline)
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

    function removeLiquidity(uint256 amount, uint256 minEth, uint256 minTokens, uint256 deadline)
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
    function getInputPrice(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve)
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
    function getOutputPrice(uint256 outputAmount, uint256 inputReserve, uint256 outputReserve)
        private
        pure
        returns (uint256 sold)
    {
        require(inputReserve > 0, "Can't calculate price with 0 input reserves");
        require(outputReserve > 0, "Cant' calculate price with 0 output reserves");
        uint256 denominator = (outputReserve - outputAmount) * 997;
        return Math.mulDiv(inputReserve, outputAmount * 1000, denominator);
    }
}
