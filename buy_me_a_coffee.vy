# Get funds from users
# Withdraw funds
# Set a minimum funding value in USD

# pragma version 0.4.0
# @ license: MIT
# @ author: Juan

interface AggregatoV3Interface:
    def decimals() -> uint8: view
    def description() -> String[1000]: view
    def version() -> uint256: view
    def latestAnswer() -> int256: view

minimum_usd: uint256
price_feed: AggregatoV3Interface #0x694AA1769357215DE4FAC081bf1f309aDC325306 -> Sepolia

@deploy
def __init__(price_feed: address):
    self.minimum_usd = as_wei_value(5, "ether")
    self.price_feed = AggregatoV3Interface(price_feed)

@external
@payable
def fund():
    """ Allows users to send $ to this contract.
    Have a minimum $ amount send

    1. How do we send ETH to this contract?
    """
    usd_value_of_eth: uint256 = self._get_eth_to_usd_rate(msg.value)
    assert usd_value_of_eth >= self.minimum_usd, "You must spend more ETH!"


@external
def withdraw():
    pass


@internal
def _get_eth_to_usd_rate(eth_amount: uint256) -> uint256:
    # Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    # ABI: 
    price: int256 = staticcall self.price_feed.latestAnswer() #3365.51000000 -> 8 decimals
    # 8 decimals
    eth_price: uint256 = convert(price, uint256) * (10 **10) #336551000000 -> 3365510000000000000000
    eth_amount_in_usd: uint256 = (eth_amount * eth_price) // 1 * (10 **18)
    return eth_amount_in_usd




#@external
#@view
#def get_Price_Feed() -> int256:
#    feed_price: AggregatoV3Interface = AggregatoV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
#    return staticcall feed_price.latestAnswer()