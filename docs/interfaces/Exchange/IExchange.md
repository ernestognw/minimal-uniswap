## `IExchange`

Interface defining a Uniswap V1 Exchange


Inspired by https://hackmd.io/C-DvwDSfSxuh-Gd4WKE_ig


### `token() → contract IERC20 token` (external)





### `factory() → contract IFactory factory` (external)





### `setup(address _token)` (external)



This function acts as a contract constructor which is not currently supported in contracts deployed
     using ERC 1167 minimal proxy. It is called once by the factory during contract creation.



### `TokenPurchase(address buyer, uint256 ethSold, uint256 tokensBought)`

Emitted when tokens are purchased for ETH.




### `EthPurchase(address buyer, uint256 tokensSold, uint256 ethBought)`

Emitted when ETH is purchased for tokens.






