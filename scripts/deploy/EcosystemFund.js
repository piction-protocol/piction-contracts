const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/ProjectStorage.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');
const pictionInput = JSON.parse(fs.readFileSync('build/contracts/PictionNetwork.json'));

module.exports = async () => {
    log(`>>>>>>>>>> [EcosystemFund] <<<<<<<<<<`);
    
    console.log('> Deploying EcosystemFund.');

    const piction = process.env.PICTIONNETWORK_ADDRESS;

    const name = 'EcosystemFund';
    const rate = 0;

    // TODO: setting distribution rate
    // const rate = caver.utils.toBN(10);
    // const rateHex = '0x' + cdRate.mul(caver.utils.toBN(10).pow(caver.utils.toBN(16))).toString('hex');

    if (!piction) {
        error('PictionNetwork is not deployed!! Please after PictionNetwork deployment.');
        return;
    }

    let instance = await contract.deploy({
        data: input.bytecode,
        arguments: [piction]
    }).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    }); 

    try {
        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /ECOSYSTEMFUND_ADDRESS=.*/g,
            to: `ECOSYSTEMFUND_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.ECOSYSTEMFUND_ADDRESS = instance.contractAddress;

    info(`EcosystemFund_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('EcosystemFund')
    }

    info(`> EcosystemFund set rate: ${rate}`)
    
    const pictionContract = new caver.klay.Contract(pictionInput.abi, piction);
    await pictionContract.methods.setRate(name, rate).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    });
}