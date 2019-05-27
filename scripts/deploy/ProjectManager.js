const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/ProjectManager.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');
const ProjectStorage = require('./ProjectStorage');
const RelationStorage = require('./RelationStorage');

module.exports = async () => {
    log(`>>>>>>>>>> [ProjectManager] <<<<<<<<<<`);
    
    console.log('> Deploying ProjectManager.');

    const piction = process.env.PICTIONNETWORK_ADDRESS;
    const accountsStorage = process.env.ACCOUNTSSTORAGE_ADDRESS;
    const relationStorage = process.env.RELATIONSTORAGE_ADDRESS;

    if (!piction) {
        error('PictionNetwork is not deployed!! Please after PictionNetwork deployment.');
        return;
    }

    if (!accountsStorage) {
        error('Project Storage is not deployed!! Please after Project Storage deployment.');
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
            from: /PROJECTMANAGER_ADDRESS=.*/g,
            to: `PROJECTMANAGER_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.PROJECTMANAGER_ADDRESS = instance.contractAddress;

    info(`ProjectManager_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('ProjectManager')
    }

    if (process.env.PROJECTSTORAGE_ADDRESS) {
        await ProjectStorage(instance.contractAddress)
    }

    if (process.env.RELATIONSTORAGE_ADDRESS) {
        await RelationStorage(instance.contractAddress)
    }
}