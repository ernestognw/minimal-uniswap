## `Exchange`

A minimal Solidity implementation of a Uniswap V1 Exchange


Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig

### `notExpired(uint64 deadline)`



Requires a deadline that hasn't expired


### `requireTokensSold(address tokenAddr, uint256 sold)`



Requires sold to be > 0


### `requireTokensBought(address tokenAddr, uint256 bought)`



Requires bought to be > 0


### `requireEthSold(uint256 sold)`



Requires sold to be > 0


### `requireEthBought(uint256 bought)`



Requires bought to be > 0


### `requireValidRecipient(address recipient)`



Checks if recipient is valid


### `requireReserves(uint256 inputReserve, uint256 outputReserve)`



Checks if reserves are > 0



### `setup(address _token)` (public)



This function acts as a contract constructor which is not currently supported in contracts deployed
     using ERC 1167 minimal proxy. It is called once by the factory during contract creation.


### `getEthToTokenInputPrice(uint256 ethSold) → uint256 tokensToBuy` (external)

Public price function for ETH to token trades with an exact input.




### `getEthToTokenOutputPrice(uint256 tokensBought) → uint256 ethNeeded` (external)

Public price function for ETH to token trades with an exact output.




### `getTokenToEthInputPrice(uint256 tokensSold) → uint256 ethToBuy` (external)

Public price function for token to ETH trades with an exact input.




### `getTokenToEthOutputPrice(uint256 ethBought) → uint256 tokensNeeded` (external)

Public price function for token to ETH trades with an exact output.




### `addLiquidity(uint256 minLiquidity, uint256 maxTokens, uint64 deadline) → uint256 minted` (external)

Deposit ETH and tokens to mint liquidity provider tokens (LPTokens).


minLiquidity does nothing when total LPTokens supply is 0 (no liquidity added yet).


### `removeLiquidity(uint256 amount, uint256 minEth, uint256 minTokens, uint64 deadline) → uint256 ethAmount, uint256 tokenAmount` (external)



Burn LPTokens tokens to withdraw ETH and Tokens at current ratio.


### `receive()` (external)

Convert ETH to tokens.


User specifies exact input (msg.value).
User cannot specify minimum output or deadline.

### `fallback()` (external)

Convert ETH to tokens.


User specifies exact input (msg.value).
User cannot specify minimum output or deadline.

### `ethToTokenSwapInput(uint256 minTokens, uint64 deadline) → uint256 tokensBought` (external)

Convert ETH to tokens.


User specifies exact input (msg.value) and minimum output.


### `ethToTokenSwapOutput(uint256 tokensBought, uint64 deadline) → uint256 ethSold` (external)

Convert ETH to tokens.


User specifies maximum input (msg.value) and exact output.


### `ethToTokenTransferInput(uint256 minTokens, uint64 deadline, address recipient) → uint256 tokensBought` (external)

Convert ETH to tokens and transfers tokens to recipient.


User specifies exact input (msg.value) and minimum output


### `ethToTokenTransferOutput(uint256 tokensBought, uint64 deadline, address recipient) → uint256 ethSold` (external)

Convert ETH to tokens and transfers tokens to recipient.


User specifies maximum input (msg.value) and exact output.


### `tokenToEthSwapInput(uint256 tokensSold, uint256 minEth, uint64 deadline) → uint256 ethBought` (external)

Convert tokens to ETH.


User specifies exact input and minimum output.


### `tokenToEthSwapOutput(uint256 ethBought, uint256 maxTokens, uint64 deadline) → uint256 tokensSold` (external)

Convert tokens to ETH.


User specifies maximum input and exact output.


### `tokenToEthTransferInput(uint256 tokensSold, uint256 minEth, uint64 deadline, address recipient) → uint256 ethBought` (external)

Convert tokens to ETH and transfers ETH to recipient.


User specifies exact input and minimum output.


### `tokenToEthTransferOutput(uint256 ethBought, uint256 maxTokens, uint64 deadline, address recipient) → uint256 tokensSold` (external)

Convert tokens to ETH and transfers ETH to recipient.


User specifies maximum input and exact output.


### `tokenToTokenSwapInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint64 deadline, address tokenAddr) → uint256 tokensBought` (external)

Convert underlying tokens to tokenAddr tokens.


User specifies exact input and minimum output.


### `tokenToTokenSwapOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint64 deadline, address tokenAddr) → uint256 tokensSold` (external)

Convert underlying tokens to tokenAddr tokens.


User specifies maximum input and exact output.


### `tokenToTokenTransferInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint64 deadline, address recipient, address tokenAddr) → uint256 tokensBought` (external)

Convert underlying tokens to tokenAddr tokens and transfers
        tokenAddr tokens to recipient.


User specifies exact input and minimum output.


### `tokenToTokenTransferOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint64 deadline, address recipient, address tokenAddr) → uint256 tokensSold` (external)

Convert underlying tokens to tokenAddr tokens and transfers
        tokenAddr tokens to recipient.


User specifies maximum input and exact output.


### `tokenToExchangeSwapInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint64 deadline, address exchangeAddr) → uint256 tokensBought` (external)

Convert underlying tokens to exchangeAddr tokens.


Allows trades through contracts that were not deployed from the same factory.
User specifies exact input and minimum output.


### `tokenToExchangeSwapOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint64 deadline, address exchangeAddr) → uint256 tokensSold` (external)

Convert underlying tokens to exchangeAddr tokens.


Allows trades through contracts that were not deployed from the same factory.
User specifies maximum input and exact output.


### `tokenToExchangeTransferInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint64 deadline, address recipient, address exchangeAddr) → uint256 tokensBought` (external)

Convert underlying tokens to exchangeAddr tokens and transfers
        exchangeAddr tokens to recipient.


Allows trades through contracts that were not deployed from the same factory.
User specifies exact input and minimum output.


### `tokenToExchangeTransferOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint64 deadline, address recipient, address exchangeAddr) → uint256 tokensSold` (external)

Convert underlying tokens to exchangeAddr tokens and transfers
        exchangeAddr tokens to recipient.


Allows trades through contracts that were not deployed from the same factory.
User specifies maximum input and exact output.





