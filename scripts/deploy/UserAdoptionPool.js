const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/UserAdoptionPool.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');

module.exports = async () => {
    log(`>>>>>>>>>> [UserAdoptionPool] <<<<<<<<<<`);
    
    console.log('> Deploying UserAdoptionPool.');

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
            from: /USERADOPTIONPOOL_ADDRESS=.*/g,
            to: `USERADOPTIONPOOL_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.USERADOPTIONPOOL_ADDRESS = instance.contractAddress;

    info(`UserAdoptionPool_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('UserAdoptionPool')
    }
}