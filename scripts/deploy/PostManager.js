const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/PostManager.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');
const ProjectStorage = require('./ProjectStorage');
const RelationStorage = require('./RelationStorage');

module.exports = async () => {
    log(`>>>>>>>>>> [PostManager] <<<<<<<<<<`);
    
    console.log('> Deploying PostManager.');

    const piction = process.env.PICTIONNETWORK_ADDRESS;
    const accountsStorage = process.env.ACCOUNTSSTORAGE_ADDRESS;
    const relationStorage = process.env.RELATIONSTORAGE_ADDRESS;

    if (!piction) {
        error('PictionNetwork is not deployed!! Please after PictionNetwork deployment.');
        return;
    }

    if (!accountsStorage) {
        error('Contents Storage is not deployed!! Please after Contents Storage deployment.');
        return;
    }

    if (!relationStorage) {
        error('Relation Storage is not deployed!! Please after Relation Storage deployment.');
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
            from: /POSTMANAGER_ADDRESS=.*/g,
            to: `POSTMANAGER_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.POSTMANAGER_ADDRESS = instance.contractAddress;

    info(`PostManager_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('setting', 'PostManager')
    }

    if (process.env.PROJECTSTORAGE_ADDRESS) {
        await ProjectStorage(instance.contractAddress)
    }

    if (process.env.RELATIONSTORAGE_ADDRESS) {
        await RelationStorage(instance.contractAddress)
    }
}