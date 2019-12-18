const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/EcosystemFund.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');
const pictionInput = JSON.parse(fs.readFileSync('build/contracts/PictionNetwork.json'));

module.exports = async (stage) => {
    log(`>>>>>>>>>> [EcosystemFund] <<<<<<<<<<`);
    
    console.log('> Deploying EcosystemFund.');

    const piction = process.env.PICTIONNETWORK_ADDRESS;

    if (!piction) {
        error('PictionNetwork is not deployed!! Please after PictionNetwork deployment.');
        return;
    }

    const name = 'EcosystemFund';
    const rate = 0;
    const rateBN = caver.utils.toBN(rate);
    const RateHex = '0x' + rateBN.mul(caver.utils.toBN(10).pow(caver.utils.toBN(16))).toString('hex');
    

    let instance = await contract.deploy({
        data: input.bytecode,
        arguments: [piction]
    }).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    }); 

    const ecosystemContract = new caver.klay.Contract(input.abi, instance.contractAddress);

    if(stage == 'cypress') {
        log('> Ecosystem Fund contract transferOwnership: ' + process.env.ECOSYSTEMFUND_OWNER);
        await ecosystemContract.methods.transferOwnership(process.env.ECOSYSTEMFUND_OWNER).send({
            from: caver.klay.accounts.wallet[0].address,
            gas: gasLimit,
            gasPrice: gasPrice
        });

        const isEcosystemOwner = await ecosystemContract.methods.isOwner().call({
            from: process.env.ECOSYSTEMFUND_OWNER
        });
        log(`Ecosystem Fund contract transfer owership result: ${isEcosystemOwner}`)
    }

    try {
        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /ECOSYSTEMFUND_ADDRESS=.*/g,
            to: `ECOSYSTEMFUND_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.ECOSYSTEMFUND_ADDRESS = instance.contractAddress;

    info(`EcosystemFund_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('setting', name)
    }

    info(`> ${name} set rate: ${rate}`)
    
    const pictionContract = new caver.klay.Contract(pictionInput.abi, piction);
    await pictionContract.methods.setRate(name, RateHex).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    });
}