const CleanEnv = require('./CleanEnv');
const PictionNetwork = require('./PictionNetwork');
const PXL = require('./PXL');
const AccountsStorage = require('./AccountsStorage');
const ContentsStorage = require('./ContentsStorage');
const RelationStorage = require('./RelationStorage');
const AccountsManager = require('./AccountsManager');
const ContentsManager = require('./ContentsManager');
const PostManager = require('./PostManager');
const ContentsRevenue = require('./ContentsRevenue');
const ContentsDistributor = require('./ContentsDistributor');
const UserAdoptionPool = require('./UserAdoptionPool');
const EcosystemFund = require('./EcosystemFund');

module.exports = async () => {
    await CleanEnv();

    await PictionNetwork();

    await PXL();

    await AccountsStorage();

    await ContentsStorage();

    await RelationStorage();

    await AccountsManager();
    
    await ContentsManager();
    
    await PostManager();

    await ContentsRevenue();

    await ContentsDistributor();

    await UserAdoptionPool();

    await EcosystemFund();
};