## `ITokenToExchangeToken`

Only Exchange's token-to-exchange's-token functions


Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig


### `tokenToExchangeSwapInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, address exchangeAddr) → uint256 tokensBought` (external)

Convert underlying tokens to exchangeAddr tokens.


Allows trades through contracts that were not deployed from the same factory.
User specifies exact input and minimum output.


### `tokenToExchangeSwapOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, address exchangeAddr) → uint256 tokensSold` (external)

Convert underlying tokens to exchangeAddr tokens.


Allows trades through contracts that were not deployed from the same factory.
User specifies maximum input and exact output.


### `tokenToExchangeTransferInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, address recipient, address exchangeAddr) → uint256 tokensBought` (external)

Convert underlying tokens to exchangeAddr tokens and transfers
        exchangeAddr tokens to recipient.


Allows trades through contracts that were not deployed from the same factory.
User specifies exact input and minimum output.


### `tokenToExchangeTransferOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, address recipient, address exchangeAddr) → uint256 tokensSold` (external)

Convert underlying tokens to exchangeAddr tokens and transfers
        exchangeAddr tokens to recipient.


Allows trades through contracts that were not deployed from the same factory.
User specifies maximum input and exact output.





