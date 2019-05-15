const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/PXL.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const decimals = caver.utils.toBN(18);
const PictionNetwork = require('./PictionNetwork');

module.exports = async () => {
    log(`>>>>>>>>>> [PXL] <<<<<<<<<<`);
    
    console.log('> Deploying PXL.');

    let instance = await contract.deploy({
        data: input.bytecode,
        arguments: []
    }).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: 2500000,
        gasPrice: gasPrice
    }); 

    console.log('> mint PXL.');
    const tokenAmount = caver.utils.toBN(process.env.TOTAL_SUPPLY)
    const tokenAmountHex = '0x' + tokenAmount.mul(caver.utils.toBN(10).pow(decimals)).toString('hex')

    const pxlContract = new caver.klay.Contract(input.abi, instance.contractAddress);

    await pxlContract.methods.mint(tokenAmountHex).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: 100000,
        gasPrice: gasPrice
    }); 

    const balance = await pxlContract.methods.balanceOf(caver.klay.accounts.wallet[0].address).call()

    console.log(balance)

    process.env.PXL_ADDRESS = instance.contractAddress;

    try {
        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /PXL_ADDRESS=.*/g,
            to: `PXL_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    info(`PXL_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('PXL')
    }
};