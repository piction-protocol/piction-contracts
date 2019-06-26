const CleanEnv = require('./CleanEnv');
const PictionNetwork = require('./PictionNetwork');
const PXL = require('./PXL');
const ProjectManager = require('./ProjectManager');
const ContentsRevenue = require('./ContentsRevenue');
const ContentsDistributor = require('./ContentsDistributor');
const UserAdoptionPool = require('./UserAdoptionPool');
const EcosystemFund = require('./EcosystemFund');
const Airdrop = require('./Airdrop');

module.exports = async () => {
    await CleanEnv();

    await PictionNetwork();

    await PXL();

    await ProjectManager('baobab');
    
    await ContentsRevenue();

    await ContentsDistributor();

    await UserAdoptionPool();

    await EcosystemFund();

    await Airdrop('baobab');
};