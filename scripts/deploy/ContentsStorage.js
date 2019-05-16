const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/ContentsStorage.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');

module.exports = async (owner) => {
    log(`>>>>>>>>>> [ContentsStorage] <<<<<<<<<<`);
    
    if (!owner) {
        await init();
    } else {
        await addOwner(owner);
    }

    log(`-------------------------------------------------------------------`);
}
    
async function init() {
    console.log('> Deploying ContentsStorage.');

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
            from: /CONTENTSSTORAGE_ADDRESS=.*/g,
            to: `CONTENTSSTORAGE_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.CONTENTSSTORAGE_ADDRESS = instance.contractAddress;

    info(`ContentsStorage_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('ContentsStorage')
    }
}

async function addOwner(owner) {
    if (!process.env.CONTENTSSTORAGE_ADDRESS) {
        error('CONTENTS STORAGE is not deployed!! Please after CONTENTS STORAGE deployment.');
        return;
    }

    console.log('> Contents Storage add owner: ' + owner);

    const contentsStorage = new caver.klay.Contract(input.abi, process.env.CONTENTSSTORAGE_ADDRESS);

    await contentsStorage.methods.addOwner(owner).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    });
}