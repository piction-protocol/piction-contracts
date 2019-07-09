const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/ProjectStorage.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');

module.exports = async (owner) => {
    log(`>>>>>>>>>> [ProjectStorage] <<<<<<<<<<`);
    
    if (!owner) {
        await init();
    } else {
        await addOwner(owner);
    }

    log(`-------------------------------------------------------------------`);
}
    
async function init() {
    console.log('> Deploying ProjectStorage.');

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
            from: /PROJECTSTORAGE_ADDRESS=.*/g,
            to: `PROJECTSTORAGE_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.PROJECTSTORAGE_ADDRESS = instance.contractAddress;

    info(`ProjectStorage_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('setting', 'ProjectStorage')
    }
}

async function addOwner(owner) {
    if (!process.env.PROJECTSTORAGE_ADDRESS) {
        error('PROJECT STORAGE is not deployed!! Please after PROJECT STORAGE deployment.');
        return;
    }

    console.log('> Project Storage add owner: ' + owner);

    const projectStorage = new caver.klay.Contract(input.abi, process.env.PROJECTSTORAGE_ADDRESS);

    await projectStorage.methods.addOwner(owner).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    });
}