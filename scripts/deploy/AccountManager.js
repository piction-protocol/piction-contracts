const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/AccountManager.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');

module.exports = async () => {
    log(`>>>>>>>>>> [AccountManager] <<<<<<<<<<`);
    
    console.log('> Deploying AccountManager.');

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
        gas: gasLimit,
        gasPrice: gasPrice
    }); 

    try {
        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /ACCOUNTMANAGER_ADDRESS=.*/g,
            to: `ACCOUNTMANAGER_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.ACCOUNTMANAGER_ADDRESS = instance.contractAddress;

    info(`ACCOUNTMANAGER_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('setting', 'AccountManager')
    }
}