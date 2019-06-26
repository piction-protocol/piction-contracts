const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/Airdrop.json'));
const contract = new caver.klay.Contract(input.abi);
const PictionNetwork = require('./PictionNetwork');
const PXL = require('./PXL');
const PXLInput = JSON.parse(fs.readFileSync('build/contracts/PXL.json'));

module.exports = async (stage) => {
    log(`>>>>>>>>>> [Airdrop] <<<<<<<<<<`);

    if(stage != 'baobab') {
        error('AIRDROP is only available on test(baobab) net.');
        return;
    }
    
    console.log('> Deploying Airdrop.');

    const piction = process.env.PICTIONNETWORK_ADDRESS;

    if (!piction) {
        error('PictionNetwork is not deployed!! Please after PictionNetwork deployment.');
        return;
    }

    const total_amount = 100000000;
    const tokenAmount = caver.utils.toBN(total_amount)
    const tokenAmountHex = '0x' + tokenAmount.mul(caver.utils.toBN(10).pow(caver.utils.toBN(18))).toString('hex')

    let instance = await contract.deploy({
        data: input.bytecode,
        arguments: [piction]
    }).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    }); 

    process.env.AIRDROP_ADDRESS = instance.contractAddress;

    info(`Airdrop_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('Airdrop')
    }

    log(`Send PXL to Airdrop contract.`);
    const pxl = new caver.klay.Contract(PXLInput.abi, process.env.PXL_ADDRESS);
    await pxl.methods.transfer(instance.contractAddress, tokenAmountHex).send({
       from: caver.klay.accounts.wallet[0].address,
       gas: gasLimit,
       gasPrice: gasPrice 
    });

    const balance = await pxl.methods.balanceOf(instance.contractAddress).call();

    info(`PXL amount of ARIDROP contract: ${balance}`);
}