interface walletAddress {
    privateKey: string,
    publicKey?: string, 
    evmAddress?: string
}

const deployer: walletAddress = {
    privateKey: "YOUR PRIVATE KEY", 
    evmAddress: "YOUR ADDRESS"
}

export default deployer