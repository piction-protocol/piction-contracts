const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/ContentsStorage.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');

module.exports = async () => {
    log(`>>>>>>>>>> [EcosystemFund] <<<<<<<<<<`);
    
    console.log('> Deploying EcosystemFund.');

    const piction = process.env.PICTIONNETWORK_ADDRESS;

    if (!piction) {
        error('PictionNetwork is not deployed!! Please after PictionNetwork deployment.');
        return;
    }

    let instance = await contract.deploy({
        data: input.bytecode,
        arguments: [piction]
    }).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: 8000000,
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
}