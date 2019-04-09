const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/PictionNetwork.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');

module.exports = async (type) => {
    log(`>>>>>>>>>> [Piction Network] <<<<<<<<<<`);

    if (!type) {
        await init();
    } else {
        await setAddress(type);
    }

    log(`-------------------------------------------------------------------`);
};

async function init() {
    console.log('> Deploying Piction Network.');

    let instance = await contract.deploy({
        data: input.bytecode,
        arguments: []
    }).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: 2000000,
        gasPrice: gasPrice
    }); 

    process.env.PICTIONNETWORK_ADDRESS = instance.contractAddress;

    try {
        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /PICTIONNETWORK_ADDRESS=.*/g,
            to: `PICTIONNETWORK_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    }  

    info(`PICTIONNETWORK_ADDRESS: ${instance.contractAddress}`);

    if (process.env.ACCOUNTSMANAGER_ADDRESS) {
        await setAddress('AccountsManager');
    }

    if (process.env.CONTENTSMANAGER_ADDRESS) {
        await setAddress('ContentsManager');
    }
}

async function setAddress(type) {
    if (!process.env.PICTIONNETWORK_ADDRESS) {
        error('PICTION NETWORK is not deployed!! Please after PICTION NETWORK deployment.');
        return;
    }
    console.log('> setAddress: ' + type);

    const pictionNetwork = new caver.klay.Contract(input.abi, process.env.PICTIONNETWORK_ADDRESS);

    var address;

    switch (type) {
    case 'AccountsManager':
        const accountsManager = process.env.ACCOUNTSMANAGER_ADDRESS;
        if (!accountsManager) {
            error('ACCOUNTS MANAGER is not deployed!! Please after ACCOUNTS MANAGER deployment.');
            break;
        }
        address = accountsManager
        break;
    case 'ContentsManager':
        const contentsManager = process.env.CONTENTSMANAGER_ADDRESS;
        if (!contentsManager) {
            error('CONTENTS MANAGER is not deployed!! Please after CONTENTS MANAGER deployment.');
            break;
        }
        address = contentsManager
        break;
    default:
        error('type is undefined.')
        break;
    }

    if (!address) {
        return;
    }

    await pictionNetwork.methods.setAddress(type, address).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: 100000,
        gasPrice: gasPrice
    });
}