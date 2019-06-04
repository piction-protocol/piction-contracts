const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/PXL.json'));
const contract = new caver.klay.Contract(input.abi);
const decimals = caver.utils.toBN(18);

module.exports = async () => {
    log(`>>>>>>>>>> [PXL] <<<<<<<<<<`);
    
    console.log('> Deploying PXL.');

    let instance = await contract.deploy({
        data: input.bytecode,
        arguments: []
    }).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    }); 

    console.log('> mint PXL.');
    const tokenAmount = caver.utils.toBN(process.env.TOTAL_SUPPLY)
    const tokenAmountHex = '0x' + tokenAmount.mul(caver.utils.toBN(10).pow(decimals)).toString('hex')

    const pxlContract = new caver.klay.Contract(input.abi, instance.contractAddress);

    await pxlContract.methods.mint(tokenAmountHex).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    }); 

    const balance = await pxlContract.methods.balanceOf(caver.klay.accounts.wallet[0].address).call()

    console.log(balance)

    process.env.PXL_ADDRESS = instance.contractAddress;

    info(`PXL_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);
};