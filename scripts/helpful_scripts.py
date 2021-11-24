from brownie import network, config, accounts, MockV3Aggregator
from web3 import Web3

FORKED_LOCAL_ENV = ["mainnet-fork", "mainnet-fork-dev"]
LOCAL_NETWORK_ENV = ["development", "ganache-local"]

DECIMALS = 8
STARTING_PRICE = 200000000000

# gets account from config if it's not devlopment network
def get_account():
    if (
        network.show_active() in LOCAL_NETWORK_ENV
        or network.show_active() in FORKED_LOCAL_ENV
    ):
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["dev"])


def deploy_mocks():
    print(f"The actvie network is {network.show_active()}")
    print("Deploying Mocks...")
    if len(MockV3Aggregator) <= 0:  # deploy only if not deployed previously
        MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from": get_account()})
    print("Mocks Deployed!")
