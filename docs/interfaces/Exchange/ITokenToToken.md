## `ITokenToToken`

Only Exchange's token-to-token functions


Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig


### `tokenToTokenSwapInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, address tokenAddr) → uint256 tokensBought` (external)

Convert underlying tokens to tokenAddr tokens.


User specifies exact input and minimum output.


### `tokenToTokenSwapOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, address tokenAddr) → uint256 tokensSold` (external)

Convert underlying tokens to tokenAddr tokens.


User specifies maximum input and exact output.


### `tokenToTokenTransferInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, address recipient, address tokenAddr) → uint256 tokensBought` (external)

Convert underlying tokens to tokenAddr tokens and transfers
        tokenAddr tokens to recipient.


User specifies exact input and minimum output.


### `tokenToTokenTransferOutput(uint256 tokens_bought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, address recipient, address tokenAddr) → uint256 tokensSold` (external)

Convert underlying tokens to tokenAddr tokens and transfers
        tokenAddr tokens to recipient.


User specifies maximum input and exact output.





