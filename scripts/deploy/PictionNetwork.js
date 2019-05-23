const fs = require('fs');
const input = JSON.parse(fs.readFileSync('build/contracts/PictionNetwork.json'));
const contract = new caver.klay.Contract(input.abi);
const replace = require('replace-in-file');

module.exports = async (type, cdAddress, cdName) => {
    log(`>>>>>>>>>> [Piction Network] <<<<<<<<<<`);

    if (!type) {
        await init();
    } else if (type == 'ContentsDistributor') {
        await setCD(cdAddress, cdName);
    } else {
        await setAddress(type);
    }

    log(`-------------------------------------------------------------------`);
};

async function init() {
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

    if (process.env.PXL_ADDRESS) {
        await setAddress('PXL');
    }

    if (process.env.ACCOUNTSSTORAGE_ADDRESS) {
        await setAddress('AccountsStorage');
    }

    if (process.env.PROJECTSTORAGE_ADDRESS) {
        await setAddress('ProjectStorage');
    }

    if (process.env.RELATIONSTORAGE_ADDRESS) {
        await setAddress('RelationStorage');
    }

    if (process.env.ACCOUNTSMANAGER_ADDRESS) {
        await setAddress('AccountsManager');
    }

    if (process.env.PROJECTMANAGER_ADDRESS) {
        await setAddress('ProjectManager');
    }

    if (process.env.POSTMANAGER_ADDRESS) {
        await setAddress('PostManager');
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
    case 'AccountsStorage':
        const accountsStorage = process.env.ACCOUNTSSTORAGE_ADDRESS;
        if (!accountsStorage) {
            error('ACCOUNTS STORAGE is not deployed!! Please after ACCOUNTS STORAGE deployment.');
            break;
        }
        address = accountsStorage;
        break;
    case 'ContentsStorage':
        const projectStorage = process.env.PROJECTSTORAGE_ADDRESS;
        if (!projectStorage) {
            error('PROJECT STORAGE is not deployed!! Please after PROJECT STORAGE deployment.');
            break;
        }
        address = projectStorage;
        break;
    case 'RelationStorage':
        const relationStorage = process.env.RELATIONSTORAGE_ADDRESS;
        if (!relationStorage) {
            error('RELATION STORAGE is not deployed!! Please after RELATION STORAGE deployment.');
            break;
        }
        address = relationStorage;
        break;
    case 'AccountsManager':
        const accountsManager = process.env.ACCOUNTSMANAGER_ADDRESS;
        if (!accountsManager) {
            error('ACCOUNTS MANAGER is not deployed!! Please after ACCOUNTS MANAGER deployment.');
            break;
        }
        address = accountsManager;
        break;
    case 'ContentsManager':
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