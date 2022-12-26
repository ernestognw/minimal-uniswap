## `IFactory`

Interface defining a Uniswap V1 Factory


Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig


### `exchangeTemplate() → address template` (external)





### `tokenCount() → uint256 count` (external)





### `createExchange(address token) → address exchange` (external)

Creates an exchange for the provided token.




### `getExchange(address token) → address exchange` (external)

Gets the exchange for the provided token.


Returns 0 when the token doesn't have an exchange.


### `getToken(address exchange) → address token` (external)

Get an underlying token given a exchange address.




### `getTokenWithId(uint256 tokenId) → address token` (external)

Get an underlying token given a tokenId.





### `NewExchange(address token, address exchange)`

Emitted when a new exchange is created






