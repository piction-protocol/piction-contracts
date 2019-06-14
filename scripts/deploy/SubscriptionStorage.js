const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/SubscriptionStorage.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');

module.exports = async (owner) => {
    log(`>>>>>>>>>> [SubscriptionStorage] <<<<<<<<<<`);
    
    if (!owner) {
        await init();
    } else {
        await addOwner(owner);
    }

    log(`-------------------------------------------------------------------`);
}
    
async function init() {
    console.log('> Deploying SubscriptionStorage.');

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
            from: /SUBSCRIPTIONSTORAGE_ADDRESS=.*/g,
            to: `SUBSCRIPTIONSTORAGE_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.SUBSCRIPTIONSTORAGE_ADDRESS = instance.contractAddress;

    info(`SubscriptionStorage_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('SubscriptionStorage')
    }
}

async function addOwner(owner) {
    if (!process.env.SUBSCRIPTIONSTORAGE_ADDRESS) {
        error('SUBSCRIPTION STORAGE is not deployed!! Please after SUBSCRIPTION STORAGE deployment.');
        return;
    }

    console.log('> Subscription Storage add owner: ' + owner);

    const subscriptionStorage = new caver.klay.Contract(input.abi, process.env.SUBSCRIPTIONSTORAGE_ADDRESS);

    await subscriptionStorage.methods.addOwner(owner).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    });
}