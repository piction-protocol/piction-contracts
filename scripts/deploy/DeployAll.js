const CleanEnv = require('./CleanEnv');
const PictionNetwork = require('./PictionNetwork');
const PXL = require('./PXL');
const ProjectManager = require('./ProjectManager');
const ContentsRevenue = require('./ContentsRevenue');
const ContentsDistributor = require('./ContentsDistributor');
const UserAdoptionPool = require('./UserAdoptionPool');
const EcosystemFund = require('./EcosystemFund');
const Airdrop = require('./Airdrop');
const Proxy = require('./Proxy');
const LogStorage = require('./LogStorage');
const ProxyBC = require('./ProxyBC');
const LogStorageBC = require('./LogStorageBC');

module.exports = async (stage) => {
    await CleanEnv();

    await PictionNetwork('deploy', stage);

    await PXL(stage);

    await LogStorage();

    await LogStorageBC();

    await Proxy();

    await ProxyBC();

    switch(stage) {
        case 'baobab':
            await ProjectManager(stage);
        
            await ContentsRevenue();
        
            await ContentsDistributor(stage);
        
            await UserAdoptionPool(stage);
        
            await EcosystemFund(stage);
        
            await Airdrop(stage);
            break;
        case 'cypress':
            await ProjectManager(stage);
            
            await ContentsRevenue();
        
            await ContentsDistributor(stage);
        
            await UserAdoptionPool(stage);
        
            await EcosystemFund(stage);
            break;
        default:
            error("stage is null, please check process argv.")
    }    
};