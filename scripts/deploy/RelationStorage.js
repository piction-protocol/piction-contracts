const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/RelationStorage.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');

module.exports = async (owner) => {
    log(`>>>>>>>>>> [RelationStorage] <<<<<<<<<<`);
    
    if (!owner) {
        await init();
    } else {
        await addOwner(owner);
    }

    log(`-------------------------------------------------------------------`);
}
    
async function init() {
    console.log('> Deploying RelationStorage.');

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
            from: /RELATIONSTORAGE_ADDRESS=.*/g,
            to: `RELATIONSTORAGE_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.RELATIONSTORAGE_ADDRESS = instance.contractAddress;

    info(`RelationStorage_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('RelationStorage')
    }
}

async function addOwner(owner) {
    if (!process.env.RELATIONSTORAGE_ADDRESS) {
        error('RELATION STORAGE is not deployed!! Please after RELATION STORAGE deployment.');
        return;
    }

    console.log('> Relation Storage add owner: ' + owner);

    const relationStorage = new caver.klay.Contract(input.abi, process.env.RELATIONSTORAGE_ADDRESS);

    await relationStorage.methods.addOwner(owner).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    });
}