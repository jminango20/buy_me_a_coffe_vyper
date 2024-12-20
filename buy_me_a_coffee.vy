# pragma version 0.4.0
"""
@license MIT
@title Buy Me A Coffee!
@author Juan
@notice This contract is for creating a sample funding contract where
    1. Get funds from users
    2. Withdraw funds
    3. Set a minimum funding value in USD
"""

interface AggregatoV3Interface:
    def decimals() -> uint8: view
    def description() -> String[1000]: view
    def version() -> uint256: view
    def latestAnswer() -> int256: view

# constant and immutable
MINIMUM_USD: public(constant(uint256)) = as_wei_value(5, "ether")
PRICE_FEED: public(immutable(AggregatoV3Interface)) #0x694AA1769357215DE4FAC081bf1f309aDC325306 -> Sepolia
OWNER: public(immutable(address))
PRECISION: constant(uint256) = (1 * (10 **18))

# Storage variables
funders: public(DynArray[address, 1000])
funder_to_amount_funded: public(HashMap[address, uint256])

# Kepp track of who sent us
# Hom much they send us

@deploy
def __init__(price_feed: address):
    PRICE_FEED = AggregatoV3Interface(price_feed)
    OWNER = msg.sender


@external
@payable
def fund():
    self._fund()

@internal
@payable
def _fund():
    """ Allows users to send $ to this contract.
    Have a minimum $ amount send

    1. How do we send ETH to this contract?
    """
    usd_value_of_eth: uint256 = self._get_eth_to_usd_rate(msg.value)
    assert usd_value_of_eth >= MINIMUM_USD, "You must spend more ETH!"
    self.funders.append(msg.sender)
    self.funder_to_amount_funded[msg.sender] += msg.value


@external
def withdraw():
    """Take the money out of the contract
    """
    assert msg.sender == OWNER, "Not the contract owner!"
    send(OWNER, self.balance) #Send the all money of the contract for the owner
    # resetting
    for funder: address in self.funders:
        self.funder_to_amount_funded[funder] = 0

    self.funders = []


@internal
def _get_eth_to_usd_rate(eth_amount: uint256) -> uint256:
    # Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    # ABI: 
    price: int256 = staticcall PRICE_FEED.latestAnswer() #3365.51000000 -> 8 decimals
    # 8 decimals
    eth_price: uint256 = convert(price, uint256) * (10 **10) #336551000000 -> 3365510000000000000000
    eth_amount_in_usd: uint256 = (eth_amount * eth_price) // PRECISION
    return eth_amount_in_usd



@external
def get_eth_to_usd_rate(eth_amount: uint256) -> uint256:
    return self._get_eth_to_usd_rate(eth_amount)

@external
@payable
def __default():
    self._fund()

#@external
#@view
#def get_Price_Feed() -> int256:
#    feed_price: AggregatoV3Interface = AggregatoV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
#    return staticcall feed_price.latestAnswer()