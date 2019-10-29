const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/Proxy.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');
const PictionNetworkInput = JSON.parse(fs.readFileSync('build/contracts/PictionNetwork.json'));

module.exports = async () => {
    log(`>>>>>>>>>> [ProxyBC] <<<<<<<<<<`);
    
    console.log('> Deploying ProxyBC.');

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
            from: /PROXYBC_ADDRESS=.*/g,
            to: `PROXYBC_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.PROXYBC_ADDRESS = instance.contractAddress;

    info(`ProxyBC_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('setting', 'ProxyBC')
    }

    const pictionNetwork = new caver.klay.Contract(PictionNetworkInput.abi, process.env.PICTIONNETWORK_ADDRESS);
    const logStorageBCAddress = await pictionNetwork.methods.getAddress("LogStorageBC").call({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    });

    const proxyContract = new caver.klay.Contract(input.abi, instance.contractAddress);
    proxyContract.methods.setTargetAddress(logStorageBCAddress).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    });
}