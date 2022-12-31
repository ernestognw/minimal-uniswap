## `ILiquidity`

Only Exchange's liquidity functions


Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig


### `addLiquidity(uint256 minLiquidity, uint256 maxTokens, uint64 deadline) → uint256 minted` (external)

Deposit ETH and tokens to mint liquidity provider tokens (LPTokens).


minLiquidity does nothing when total LPTokens supply is 0 (no liquidity added yet).


### `removeLiquidity(uint256 amount, uint256 minEth, uint256 minTokens, uint64 deadline) → uint256 ethAmount, uint256 tokenAmount` (external)



Burn LPTokens tokens to withdraw ETH and Tokens at current ratio.



### `AddLiquidity(address provider, uint256 ethAmount, uint256 tokenAmount)`

Emitted when liquidity is added for a pair.




### `RemoveLiquidity(address provider, uint256 ethAmount, uint256 tokenAmount)`

Emitted when liquidity is removed for a pair.






