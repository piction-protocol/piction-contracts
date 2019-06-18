const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/ContentsDistributor.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');
const decimals = caver.utils.toBN(18);
const pictionInput = JSON.parse(fs.readFileSync('build/contracts/PictionNetwork.json'));

module.exports = async () => {
    log(`>>>>>>>>>> [ContentsDistributor] <<<<<<<<<<`);
    
    console.log('> Deploying ContentsDistributor.');

    const piction = process.env.PICTIONNETWORK_ADDRESS;

    if (!piction) {
        error('PictionNetwork is not deployed!! Please after PictionNetwork deployment.');
        return;
    }

    const initialStaking = caver.utils.toBN(1);
    const initialStakingHex = '0x' + initialStaking.mul(caver.utils.toBN(10).pow(decimals)).toString('hex');
    const cdRate = caver.utils.toBN(10);
    const cdRateHex = '0x' + cdRate.mul(caver.utils.toBN(10).pow(caver.utils.toBN(16))).toString('hex');
    const cdAddress = '0xc73DB144887fEAE6150E01df9D48F0293f26256f';
    const cdName = 'PictionNetworkCD';

    let instance = await contract.deploy({
        data: input.bytecode,
        arguments: [piction, initialStakingHex, cdRateHex, cdAddress, cdName]
    }).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    }); 

    try {
        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /CONTENTSDISTRIBUTOR_ADDRESS=.*/g,
            to: `CONTENTSDISTRIBUTOR_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.CONTENTSDISTRIBUTOR_ADDRESS = instance.contractAddress;

    info(`ContentsDistributor_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('ContentsDistributor', instance.contractAddress, cdName)
    }
}