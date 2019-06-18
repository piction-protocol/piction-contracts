const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/AccountsManager.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');
const PictionNetwork = require('./PictionNetwork');
const AccountsStorage = require('./AccountsStorage');
const PXL = require('./PXL');
const PXLInput = JSON.parse(fs.readFileSync('build/contracts/PXL.json'));


module.exports = async () => {
    log(`>>>>>>>>>> [AccountsManager] <<<<<<<<<<`);
    
    console.log('> Deploying AccountsManager.');

    const total_amount = 100000000;
    const tokenAmount = caver.utils.toBN(total_amount)
    const tokenAmountHex = '0x' + tokenAmount.mul(caver.utils.toBN(10).pow(caver.utils.toBN(18))).toString('hex')

    const piction = process.env.PICTIONNETWORK_ADDRESS;
    const accountsStorage = process.env.ACCOUNTSSTORAGE_ADDRESS;

    if (!piction) {
        error('PictionNetwork is not deployed!! Please after PictionNetwork deployment.');
        return;
    }

    if (!accountsStorage) {
        error('Accounts Storage is not deployed!! Please after Accounts Storage deployment.');
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
            from: /ACCOUNTSMANAGER_ADDRESS=.*/g,
            to: `ACCOUNTSMANAGER_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    } 

    process.env.ACCOUNTSMANAGER_ADDRESS = instance.contractAddress;

    info(`AccountsManager_ADDRESS: ${instance.contractAddress}`);
    log(`-------------------------------------------------------------------`);

    log(`Send PXL to AccountManager.`);
    const pxl = new caver.klay.Contract(PXLInput.abi, process.env.PXL_ADDRESS);
    await pxl.methods.transfer(instance.contractAddress, tokenAmountHex).send({
       from: caver.klay.accounts.wallet[0].address,
       gas: gasLimit,
       gasPrice: gasPrice 
    });

    const balance = await pxl.methods.balanceOf(instance.contractAddress).call();

    info(`PXL amount of AccountManager contract: ${balance}`);
    

    if (process.env.PICTIONNETWORK_ADDRESS) {
        await PictionNetwork('AccountsManager')
    }

    if (process.env.ACCOUNTSSTORAGE_ADDRESS) {
        await AccountsStorage(instance.contractAddress)
    }
}