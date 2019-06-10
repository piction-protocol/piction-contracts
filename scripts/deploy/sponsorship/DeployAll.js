const PXL = require('./PXL');
const SponsorshipConnector = require('./SponsorshipConnector');

module.exports = async () => {
    await PXL();

    await SponsorshipConnector();
}