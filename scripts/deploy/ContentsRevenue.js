const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/ContentsRevenue.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');
const pictionInput = JSON.parse(fs.readFileSync('build/contracts/PictionNetwork.json'));

module.exports = async () => {
    log(`>>>>>>>>>> [ContentsRevenue] <<<<<<<<<<`);
    
    console.log('> Deploying ContentsRevenue.');

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
            from: /CONTENTSREVENUE_ADDRESS=.*/g,
            to: `CONTENTSREVENUE_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.CONTENTSREVENUE_ADDRESS = instance.contractAddress;

    info(`ContentsRevenue_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    const pictionContract = new caver.klay.Contract(pictionInput.abi, piction);
    const cdAddress = await pictionContract.methods.getContentsDistributor('PictionNetworkCD').call();
    if (cdAddress != '0x0000000000000000000000000000000000000000') {
        info(`> ContentsDistributor update address...`);

        await pictionContract.methods.updateAddress([cdAddress]).send({
            from: caver.klay.accounts.wallet[0].address,
            gas: gasLimit,
            gasPrice: gasPrice
        });
    }

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('ContentsRevenue')
    }
}