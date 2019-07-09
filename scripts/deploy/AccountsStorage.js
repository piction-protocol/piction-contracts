const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/AccountsStorage.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');

module.exports = async (owner) => {
    log(`>>>>>>>>>> [AccountsStorage] <<<<<<<<<<`);
    
    if (!owner) {
        await init();
    } else {
        await addOwner(owner);
    }

    log(`-------------------------------------------------------------------`);
}
    
async function init() {
    console.log('> Deploying AccountsStorage.');

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
            from: /ACCOUNTSSTORAGE_ADDRESS=.*/g,
            to: `ACCOUNTSSTORAGE_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.ACCOUNTSSTORAGE_ADDRESS = instance.contractAddress;

    info(`AccountsStorage_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('setting', 'AccountsStorage')
    }
}

async function addOwner(owner) {
    if (!process.env.ACCOUNTSSTORAGE_ADDRESS) {
        error('ACCOUNTS STORAGE is not deployed!! Please after ACCOUNTS STORAGE deployment.');
        return;
    }

    console.log('> Accounts Storage add owner: ' + owner);

    const accountsStorage = new caver.klay.Contract(input.abi, process.env.ACCOUNTSSTORAGE_ADDRESS);

    await accountsStorage.methods.addOwner(owner).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    });
}