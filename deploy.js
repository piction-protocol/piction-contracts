
var stage;

if(process.argv.length <= 2) {
    console.error(`Please check parameter. ex) node deploy.js cypress[baobab]`)
    return;
}

stage = process.argv[2];
console.log('current env: ' + stage);


require('dotenv-flow').config({default_node_env: stage});
const colors = require('colors');
const BigNumber = require('bignumber.js');
const Compile = require('./scripts/deploy/Compile');
  
global.Caver = require('caver-js');
global.caver = new Caver(new Caver.providers.HttpProvider(process.env.RPC_NODE));

global.log = (message) => console.log(colors.green.bold(message));
global.info = (message) => console.log(colors.white.bold(message));
global.error = (message) => console.log(colors.red.bold(message));
global.ether = (value) => new BigNumber(value * Math.pow(10, 18));
global.gasPrice = '25000000000'
global.gasLimit = 8000000

log('current RPC_NODE: ' + process.env.RPC_NODE);


if (process.env.PRIVATE_KEY) {
    caver.klay.accounts.wallet.add('0x' + process.env.PRIVATE_KEY);
    log(`CURRENT_ADDRESS : ${caver.klay.accounts.wallet[0].address}`);
} else {
    error(`Please register your private key! (.env.${process.env.NODE_ENV} file)`)
    process.exit(0)
}

Compile(stage)
