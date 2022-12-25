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

    function addLiquidity(
        uint256 minLiquidity,
        uint256 maxTokens,
        uint256 deadline
    ) external payable override returns (uint256 minted) {
        require(deadline > block.timestamp, "Exchange: Expired transaction");
        require(maxTokens > 0, "Exchange: maxTokens amount can't be 0");
        require(msg.value > 0, "Exchange: ETH amount can't be 0");

        uint256 totalLiquidity = totalSupply();

        if (totalLiquidity > 0) {
            require(minLiquidity > 0, "Exchange: minLiquidity can't be 0");
            uint256 ethReserve = address(this).balance - msg.value;
            uint256 tokenReserve = token.balanceOf(address(this));
            uint256 tokenAmount = Math.mulDiv(
                msg.value,
                tokenReserve,
                ethReserve
            );
            uint256 liquidityMinted = Math.mulDiv(
                msg.value,
                totalLiquidity,
                ethReserve
            );
            require(
                maxTokens >= tokenAmount,
                "Exchange: Token amount to deposit exceeds maxTokens"
            );
            require(
                liquidityMinted >= minLiquidity,
                "Exchange: LPTokens to receive are less than minLiquidity"
            );
            _mint(msg.sender, liquidityMinted);
            token.safeTransferFrom(msg.sender, address(this), tokenAmount);
            emit AddLiquidity(msg.sender, msg.value, tokenAmount);
            return liquidityMinted;
        } else {
            require(
                msg.value >= 1 gwei,
                "Exchange: Min 1 gwei ETH liquidity not met"
            );
            assert(factory.getExchange(address(token)) == address(this));
            uint256 tokenAmount = maxTokens;
            uint256 initialLiquidity = address(this).balance;
            _mint(msg.sender, initialLiquidity);
            token.safeTransferFrom(msg.sender, address(this), tokenAmount);
            emit AddLiquidity(msg.sender, msg.value, tokenAmount);
            return initialLiquidity;
        }
    }

    function removeLiquidity(
        uint256 amount,
        uint256 minEth,
        uint256 minTokens,
        uint256 deadline
    ) external override returns (uint256 ethAmount, uint256 tokenAmount) {
        require(deadline > block.timestamp, "Exchange: Expired transaction");
        require(amount > 0, "Exchange: amount amount can't be 0");
        require(minEth > 0, "Exchange: minEth amount can't be 0");
        require(minTokens > 0, "Exchange: minTokens amount can't be 0");

        uint256 totalLiquidity = totalSupply();
        require(totalLiquidity > 0, "Exchange: No liqiduity available");

        uint256 ethAmount = Math.mulDiv(
            amount,
            address(this).balance,
            totalLiquidity
        );
        uint256 tokenAmount = Math.mulDiv(
            amount,
            token.balanceOf(address(this)),
            totalLiquidity
        );

        require(ethAmount >= minEth, "Exchange: minEth to receive not met");
        require(
            tokenAmount >= minTokens,
            "Exchange: minTokens to receive not met"
        );

        _burn(msg.sender, amount);

        payable(msg.sender).transfer(ethAmount);
        token.safeTransfer(msg.sender, tokenAmount);

        emit RemoveLiquidity(msg.sender, ethAmount, tokenAmount);

        return (ethAmount, tokenAmount);
    }
}
