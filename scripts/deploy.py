from brownie import FundMe, network, config, MockV3Aggregator
from scripts.helpful_scripts import get_account, deploy_mocks, LOCAL_NETWORK_ENV


def deploy_fund_me():
    acount = get_account()
    # pass the price feed address to funme contract
    # if we are on a persistent network like rinkeby, use associated address
    # otherwise deploy mocks
    if network.show_active() not in LOCAL_NETWORK_ENV:
        price_feed_address = config["networks"][network.show_active()][
            "ETHUSD_pricefeed"
        ]
    else:  # Use a mock aggregator function if on development network
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": acount},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    print(f"Contract deployed to {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()
