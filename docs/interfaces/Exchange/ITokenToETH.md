## `ITokenToETH`

Only Exchange's token-to-ETH functions


Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig


### `tokenToEthSwapInput(uint256 tokensSold, uint256 minEth, uint256 deadline) → uint256 ethBought` (external)

Convert Tokens to ETH.


User specifies exact input and minimum output.


### `tokenToEthSwapOutput(uint256 ethBought, uint256 maxTokens, uint256 deadline) → uint256 tokensSold` (external)

Convert tokens to ETH.


User specifies maximum input and exact output.


### `tokenToEthTransferInput(uint256 tokensSold, uint256 minEth, uint256 deadline, address recipient) → uint256 ethBought` (external)

Convert tokens to ETH and transfers ETH to recipient.


User specifies exact input and minimum output.


### `tokenToEthTransferOutput(uint256 ethBought, uint256 max_tokens, uint256 deadline, address recipient) → uint256 tokensSold` (external)

Convert tokens to ETH and transfers ETH to recipient.


User specifies maximum input and exact output.





