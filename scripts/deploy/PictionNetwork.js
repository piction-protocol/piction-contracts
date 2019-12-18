const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/PictionNetwork.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');

module.exports = async (type, name, cdAddress, cdName) => {
    log(`>>>>>>>>>> [Piction Network] <<<<<<<<<<`);

    if (type == 'deploy') {
        await init(name);
    } else if (type == 'setting') {
        if(name == 'ContentsDistributor') {
            await setCD(cdAddress, cdName);
        } else {
            await setAddress(name);
        }
    } else {
        error('Invalid parameter, please check parameter.');
        return;
    }

    log(`-------------------------------------------------------------------`);
};

async function init(name) {
    console.log('> Deploying Piction Network.');

    let instance = await contract.deploy({
        data: input.bytecode,
        arguments: []
    }).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    }); 

    process.env.PICTIONNETWORK_ADDRESS = instance.contractAddress;

    try {
        await replace({
            files: `.env.${process.env.NODE_ENV}`,
            from: /PICTIONNETWORK_ADDRESS=.*/g,
            to: `PICTIONNETWORK_ADDRESS=${instance.contractAddress}`
        });
    }
    catch (error) {
        console.error('Error occurred: ', error);
    }  

    info(`PICTIONNETWORK_ADDRESS: ${instance.contractAddress}`);


    if(name == 'cypress' || name == 'baobab' || name == 'local') {
        log(`PICTIONNETWORK add owner: ${process.env.PICTIONNETWORK_OWNER}`)
        const pictionNetwork = new caver.klay.Contract(input.abi, process.env.PICTIONNETWORK_ADDRESS);
        await pictionNetwork.methods.addOwner(process.env.PICTIONNETWORK_OWNER).send({
            from: caver.klay.accounts.wallet[0].address,
            gas: gasLimit,
            gasPrice: gasPrice
        });

        const isPictionOwner = await pictionNetwork.methods.owners(process.env.PICTIONNETWORK_OWNER).call();
        log(`PICTIONNETWORK contract add owner result: ${isPictionOwner}`)
    }

    if (process.env.PXL_ADDRESS) {
        await setAddress('PXL');
    }

    if (process.env.ACCOUNTMANAGER_ADDRESS) {
        await setAddress('AccountManager');
    }

    if (process.env.PROJECTMANAGER_ADDRESS) {
        await setAddress('ProjectManager');
    }

    if (process.env.CONTENTSREVENUE_ADDRESS) {
        await setAddress('ContentsRevenue');
    }

    if (process.env.USERADOPTIONPOOL_ADDRESS) {
        await setAddress('UserAdoptionPool');
    }

    if (process.env.ECOSYSTEMFUND_ADDRESS) {
        await setAddress('EcosystemFund');
    }

    if (process.env.AIRDROP_ADDRESS) {
        await setAddress('Airdrop');
    }

    if (process.env.PROXY_ADDRESS) {
        await setAddress('Proxy');
    }

    if (process.env.LOGSTORAGE_ADDRESS) {
        await setAddress('LogStorage');
    }

    if (process.env.PROXYBC_ADDRESS) {
        await setAddress('ProxyBC');
    }

    if (process.env.LOGSTORAGEBC_ADDRESS) {
        await setAddress('LogStorageBC');
    }
}

async function setAddress(type) {
    if (!process.env.PICTIONNETWORK_ADDRESS) {
        error('PICTION NETWORK is not deployed!! Please after PICTION NETWORK deployment.');
        return;
    }
    console.log('> setAddress: ' + type);

    const pictionNetwork = new caver.klay.Contract(input.abi, process.env.PICTIONNETWORK_ADDRESS);

    var address;

    switch (type) {
    case 'PXL':
        const pxl = process.env.PXL_ADDRESS;
        if (!pxl) {
            error('PXL is not deployed!! Please after PXL deployment.');
            break;
        }
        address = pxl;
        break;
    case 'AccountManager':
        const accountManager = process.env.ACCOUNTMANAGER_ADDRESS;
        if (!accountManager) {
            error('ACCOUNT MANAGER is not deployed!! Please after ACCOUNT MANAGER deployment.');
            break;
        }
        address = accountManager;
        break;
    case 'ProjectManager':
        const projectManager = process.env.PROJECTMANAGER_ADDRESS;
        if (!projectManager) {
            error('PROJECT MANAGER is not deployed!! Please after PROJECT MANAGER deployment.');
            break;
        }
        address = projectManager;
        break;
    case 'PostManager':
        const postManager = process.env.POSTMANAGER_ADDRESS;
        if (!postManager) {
            error('POST MANAGER is not deployed!! Please after POST MANAGER deployment.');
            break;
        }
        address = postManager;
        break;
    case 'ContentsRevenue':
        const contentsRevenue = process.env.CONTENTSREVENUE_ADDRESS;
        if (!contentsRevenue) {
            error('CONTENTS REVENUE is not deployed!! Please after CONTENTS REVENUE deployment.');
            break;
        }
        address = contentsRevenue;
        break;
    case 'UserAdoptionPool':
        const userAdoptionPool = process.env.USERADOPTIONPOOL_ADDRESS;
        if (!userAdoptionPool) {
            error('USER ADOPTION POOL is not deployed!! Please after USER ADOPTION POOL deployment.');
            break;
        }
        address = userAdoptionPool;
        break;
    case 'EcosystemFund':
        const ecosystemFund = process.env.ECOSYSTEMFUND_ADDRESS;
        if (!ecosystemFund) {
            error('ECOSYSTEM FUND is not deployed!! Please after ECOSYSTEM FUND deployment.');
            break;
        }
        address = ecosystemFund;
        break;
    case 'Airdrop':
        const airdrop = process.env.AIRDROP_ADDRESS;
        if (!airdrop) {
            error('AIRDROP is not deployed!! Please after AIRDROP deployment.');
            break;
        }
        address = airdrop;
        break;
    case 'Proxy':
        const proxy = process.env.PROXY_ADDRESS;
        if (!proxy) {
            error('PROXY is not deployed!! Please after PROXY deployment.');
            break;
        }
        address = proxy;
        break;
    case 'LogStorage':
        const logStorage = process.env.LOGSTORAGE_ADDRESS;
        if (!logStorage) {
            error('LOGSTORAGE is not deployed!! Please after LOGSTORAGE deployment.');
            break;
        }
        address = logStorage;
        break;
    case 'ProxyBC':
        const proxyBC = process.env.PROXYBC_ADDRESS;
        if (!proxyBC) {
            error('PROXYBC is not deployed!! Please after PROXYBC deployment.');
            break;
        }
        address = proxyBC;
        break;
    case 'LogStorageBC':
        const logStorageBC = process.env.LOGSTORAGEBC_ADDRESS;
        if (!logStorageBC) {
            error('LOGSTORAGEBC is not deployed!! Please after LOGSTORAGEBC deployment.');
            break;
        }
        address = logStorageBC;
        break;
    default:
        error('type is undefined.')
        break;
    }

    if (!address) {
        return;
    }

    await pictionNetwork.methods.setAddress(type, address).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    });
}

async function setCD(cdAddress, cdName) {
    if (!process.env.PICTIONNETWORK_ADDRESS) {
        error('PICTION NETWORK is not deployed!! Please after PICTION NETWORK deployment.');
        return;
    }
    console.log('> setContentsDistributor: ' + cdName, cdAddress);

    const pictionNetwork = new caver.klay.Contract(input.abi, process.env.PICTIONNETWORK_ADDRESS);

    const contentsRevenue = process.env.CONTENTSREVENUE_ADDRESS;
    if (!contentsRevenue) {
        error('CONTENTS REVENUE is not deployed!! Please after CONTENTS REVENUE deployment.');
        return;
    }

    await pictionNetwork.methods.setContentsDistributor(cdName, cdAddress).send({
        from: caver.klay.accounts.wallet[0].address,
        gas: gasLimit,
        gasPrice: gasPrice
    });
}