## `Exchange`

A minimal Solidity implementation of a Uniswap V1 Exchange


Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig


### `constructor(address _token, string name, string symbol)` (internal)





### `getEthToTokenInputPrice(uint256 ethSold) → uint256 tokensToBuy` (external)





### `getEthToTokenOutputPrice(uint256 tokensBought) → uint256 ethNeeded` (external)





### `getTokenToEthInputPrice(uint256 tokensSold) → uint256 ethToBuy` (external)





### `getTokenToEthOutputPrice(uint256 ethBought) → uint256 tokensNeeded` (external)





### `addLiquidity(uint256 minLiquidity, uint256 maxTokens, uint64 deadline) → uint256 minted` (external)





### `removeLiquidity(uint256 amount, uint256 minEth, uint256 minTokens, uint64 deadline) → uint256 ethAmount, uint256 tokenAmount` (external)





### `receive()` (external)





### `fallback()` (external)





### `ethToTokenSwapInput(uint256 minTokens, uint64 deadline) → uint256 tokensBought` (external)





### `ethToTokenSwapOutput(uint256 tokensBought, uint64 deadline) → uint256 ethSold` (external)





### `ethToTokenTransferInput(uint256 minTokens, uint64 deadline, address recipient) → uint256 tokensBought` (external)





### `ethToTokenTransferOutput(uint256 tokensBought, uint64 deadline, address recipient) → uint256 ethSold` (external)








