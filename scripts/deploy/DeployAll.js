const CleanEnv = require('./CleanEnv');
const PictionNetwork = require('./PictionNetwork');
const PXL = require('./PXL');
const AccountsStorage = require('./AccountsStorage');
const ProjectStorage = require('./ProjectStorage');
const RelationStorage = require('./RelationStorage');
const SubscriptionStorage = require('./SubscriptionStorage');
const AccountsManager = require('./AccountsManager');
const ProjectManager = require('./ProjectManager');
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

    await ProjectStorage();

    await RelationStorage();

    await SubscriptionStorage();

    await AccountsManager();
    
    await ProjectManager();
    
    await PostManager();

    await ContentsRevenue();

    await ContentsDistributor();

    await UserAdoptionPool();

    await EcosystemFund();
};