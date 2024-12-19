# Get funds from users
# Withdraw funds
# Set a minimum funding value in USD

# pragma version 0.4.0
# @ license: MIT
# @ author: Juan

minimum_usd: uint256

@deploy
def __init__():
    self.minimum_usd = 5

@external
@payable
def fund():
    """ Allows users to send $ to this contract.
    Have a minimum $ amount send

    1. How do we send ETH to this contract?
    """
    assert msg.value >= as_wei_value(1, "ether"), "You must spend more ETH!"




@external
def withdraw():
    pass