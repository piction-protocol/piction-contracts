const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/SponsorshipConnector.json'));
const contract = new caver.klay.Contract(input.abi);

module.exports = async () => {
    log(`>>>>>>>>>> [SponsorshipConnector] <<<<<<<<<<`);
    
    console.log('> Deploying SponsorshipConnector.');

    const pxl = process.env.PXL_ADDRESS;

    if (!pxl) {
        error('PXL is not deployed!! Please after PXL deployment.');
        return;
    }

    let instance = await contract.deploy({
        data: input.bytecode,
        arguments: [pxl]
    }).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    }); 

    info(`SponsorshipConnector_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);


}