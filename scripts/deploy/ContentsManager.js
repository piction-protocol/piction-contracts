const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/ContentsManager.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');
const ContentsStorage = require('./ContentsStorage');
const RelationStorage = require('./RelationStorage');

module.exports = async () => {
    log(`>>>>>>>>>> [ContentsManager] <<<<<<<<<<`);
    
    console.log('> Deploying ContentsManager.');

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
        gas: 8000000,
        gasPrice: gasPrice
    }); 

    try {
        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /CONTENTSMANAGER_ADDRESS=.*/g,
            to: `CONTENTSMANAGER_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.CONTENTSMANAGER_ADDRESS = instance.contractAddress;

    info(`ContentsManager_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('ContentsManager')
    }

    if (process.env.CONTENTSSTORAGE_ADDRESS) {
        await ContentsStorage(instance.contractAddress)
    }

    if (process.env.RELATIONSTORAGE_ADDRESS) {
        await RelationStorage(instance.contractAddress)
    }
}