## `IETHToToken`

Only Exchange's ETH-to-token functions


Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig


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


### `fallback()` (external)

Convert ETH to tokens.


User specifies exact input (msg.value).
User cannot specify minimum output or deadline.

### `receive()` (external)

Convert ETH to tokens.


User specifies exact input (msg.value).
User cannot specify minimum output or deadline.




