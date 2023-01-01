## `Factory`

A minimal Solidity implementation of a Uniswap V1 Factory


Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig


### `constructor(address template)` (public)





### `createExchange(address token) → address exchange` (external)

Creates an exchange for the provided token.




### `getExchange(address token) → address exchange` (external)

Gets the exchange for the provided token.


Returns 0 when the token doesn't have an exchange.


### `getToken(address exchange) → address token` (external)

Get an underlying token given a exchange address.




### `getTokenWithId(uint256 tokenId) → address token` (external)

Get an underlying token given a tokenId.







