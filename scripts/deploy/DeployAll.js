const CleanEnv = require('./CleanEnv');
const PictionNetwork = require('./PictionNetwork');
const PXL = require('./PXL');
const AccountsStorage = require('./AccountsStorage');
const ProjectStorage = require('./ProjectStorage');
const RelationStorage = require('./RelationStorage');
const AccountsManager = require('./AccountsManager');
const ProjectManager = require('./ProjectManager');
const PostManager = require('./PostManager');
const ContentsRevenue = require('./ContentsRevenue');
const ContentsDistributor = require('./ContentsDistributor');
const UserAdoptionPool = require('./UserAdoptionPool');
const EcosystemFund = require('./EcosystemFund');
const Airdrop = require('./Airdrop');

module.exports = async (stage) => {
    await CleanEnv();

    await PictionNetwork('deploy', stage);

    await PXL(stage);

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